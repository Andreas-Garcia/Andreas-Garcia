#!/bin/bash

# Script to free up cache space on macOS
# This script safely clears various cache directories

set -e

# Claude Code conversation transcripts (*.jsonl) older than this are proposed for
# deletion in the final alert below (opt-in, never automatic). Only the transcript
# files are targeted — memory notes (memory/*.md) are untouched either way.
CLAUDE_CONV_PURGE_DAYS=21

# Root scanned for repo-local build caches (Nx, Turbo, Next, node_modules/.cache, Python tool caches)
CODE_ROOT="$HOME/git"

# Worktrees with no file modified in this many days get node_modules/.venv/dist etc. removed
STALE_WORKTREE_DAYS=1

# Running total of space actually freed (KB), tracked per-operation rather than
# inferred from a before/after `df` snapshot — `df` on APFS is unreliable for this
# since deleted blocks can stay "purgeable" (not yet reported as free) for a while.
TOTAL_FREED_KB=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get directory size
get_size() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | awk '{print $1}'
    else
        echo "0B"
    fi
}

# Function to get directory size in bytes (for calculation)
get_size_bytes() {
    if [ -d "$1" ]; then
        local size
        size=$(du -sk "$1" 2>/dev/null | awk '{print $1}')
        echo "${size:-0}"
    else
        echo "0"
    fi
}

# Function to clear cache directory
# Optional remaining args: names of entries directly under cache_dir to skip (e.g. a
# cache that's expensive to redownload, like Playwright's browser binaries, or one
# managed by its own tool, like Homebrew's).
clear_cache() {
    local cache_dir=$1
    local description=$2
    shift 2
    local excludes=("$@")

    if [ ! -d "$cache_dir" ]; then
        echo -e "${YELLOW}⚠️  $description: Directory not found, skipping${NC}"
        return
    fi

    local size_before=$(get_size_bytes "$cache_dir")
    local size_before_human=$(get_size "$cache_dir")

    echo -e "${YELLOW}Clearing: $description${NC}"
    echo "  Location: $cache_dir"
    echo "  Size before: $size_before_human"

    # Remove contents but keep directory structure
    if [ "${#excludes[@]}" -gt 0 ]; then
        local prune_args=()
        for name in "${excludes[@]}"; do
            prune_args+=(! -name "$name")
        done
        find "$cache_dir" -mindepth 1 -maxdepth 1 "${prune_args[@]}" -exec rm -rf {} + 2>/dev/null || true
    else
        find "$cache_dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    fi

    local size_after=$(get_size_bytes "$cache_dir")
    local size_freed=$((size_before - size_after))
    local size_freed_mb=$((size_freed / 1024))

    if [ "$size_freed" -gt 0 ]; then
        TOTAL_FREED_KB=$((TOTAL_FREED_KB + size_freed))
    fi

    if [ $size_freed_mb -gt 0 ]; then
        echo -e "${GREEN}  ✓ Freed: ${size_freed_mb}MB${NC}"
    else
        echo -e "${GREEN}  ✓ Already clean${NC}"
    fi
    echo ""
}

# Prune VS Code-style workspaceStorage entries whose folder no longer exists on disk.
# Only local file:// folders without URL-encoding are judged; remote/encoded URIs are kept
# since their path can't be checked with a plain -d test.
prune_workspace_storage() {
    local storage_dir=$1
    local app=$2
    [ -d "$storage_dir" ] || return 0
    echo -e "${YELLOW}Pruning: $app workspaceStorage (orphaned workspaces)${NC}"
    local pruned=0 ws_dir folder size_kb
    for ws_dir in "$storage_dir"/*/; do
        [ -f "$ws_dir/workspace.json" ] || continue
        folder=$(grep -o '"folder":"file://[^"]*"' "$ws_dir/workspace.json" 2>/dev/null | head -1 | sed 's/"folder":"file:\/\///;s/"//')
        [[ -n "$folder" && "$folder" != *%* ]] || continue
        if [ ! -d "$folder" ]; then
            size_kb=$(du -sk "$ws_dir" 2>/dev/null | awk '{print $1}')
            rm -rf "$ws_dir"
            pruned=$((pruned + ${size_kb:-0}))
        fi
    done
    if [ "$pruned" -gt 0 ]; then
        TOTAL_FREED_KB=$((TOTAL_FREED_KB + pruned))
        echo -e "${GREEN}  ✓ Freed: $((pruned / 1024))MB (orphaned workspaces)${NC}"
    else
        echo -e "${GREEN}  ✓ No orphaned workspaces found${NC}"
    fi
    echo ""
}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}macOS Cache Cleanup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check available space before
echo -e "${YELLOW}Current disk space:${NC}"
df -h / | tail -1
echo ""

# Get initial free space
initial_free=$(df -k / | tail -1 | awk '{print $4}')

# User caches (keep Homebrew — "brew cleanup" below manages its own cache, otherwise
# it has to re-download the ~15MB API JSON on every run)
clear_cache "$HOME/Library/Caches" "User Library Caches" "Homebrew"

# Playwright browser binaries (re-downloaded on next `npx playwright install`/test run)
clear_cache "$HOME/Library/Caches/ms-playwright" "Playwright Browser Binaries"

# Browser caches (optional - uncomment if needed)
# clear_cache "$HOME/Library/Caches/Google/Chrome" "Chrome Cache"
# clear_cache "$HOME/Library/Caches/com.apple.Safari" "Safari Cache"
# clear_cache "$HOME/Library/Caches/com.mozilla.firefox" "Firefox Cache"

# Google Chrome caches
for chrome_profile in "$HOME/Library/Application Support/Google/Chrome/Default" "$HOME/Library/Application Support/Google/Chrome/Profile "*; do
    [ -d "$chrome_profile" ] || continue
    profile_name=$(basename "$chrome_profile")
    clear_cache "$chrome_profile/Cache" "Chrome Cache ($profile_name)"
    clear_cache "$chrome_profile/Code Cache" "Chrome Code Cache ($profile_name)"
    clear_cache "$chrome_profile/GPUCache" "Chrome GPU Cache ($profile_name)"
done
clear_cache "$HOME/Library/Application Support/Google/GoogleUpdater/crx_cache" "Google Updater crx_cache"

# Xcode derived data (if exists)
clear_cache "$HOME/Library/Developer/Xcode/DerivedData" "Xcode Derived Data"

# Xcode archives (if exists)
clear_cache "$HOME/Library/Developer/Xcode/Archives" "Xcode Archives"

# Repo-local build caches — all regenerated on next build/lint/test; only cost is a cold rebuild.
# node_modules is pruned (except its .cache) so the scan stays fast; depth covers
# <repo>/.claude/worktrees/<wt>/packages/<pkg>/.turbo.
if [ -d "$CODE_ROOT" ]; then
    while IFS= read -r dir; do
        [ "$(get_size_bytes "$dir")" -gt 0 ] || continue
        clear_cache "$dir" "Repo build cache"
    done < <(find "$CODE_ROOT" -maxdepth 7 \
        \( -name .git -o \( -path '*/node_modules/*' ! -path '*/node_modules/.cache' \) \) -prune -o \
        -type d \( -path '*/.nx/cache' -o -path '*/.nx/workspace-data' -o -name .turbo \
            -o -path '*/node_modules/.cache' -o -path '*/.next/cache' -o -path '*/.next/dev' \
            -o -name .pytest_cache -o -name .mypy_cache -o -name .ruff_cache \) \
        -print -prune 2>/dev/null)
else
    echo -e "${YELLOW}⚠️  Repo build caches: $CODE_ROOT not found, skipping${NC}"
    echo ""
fi

# Dependency/build dirs in git worktrees with no file edited for STALE_WORKTREE_DAYS.
# Only gitignored dirs are removed; reinstall/rebuild if the worktree is picked up again.
# Submodules also have a .git file, so only gitdirs pointing into .git/worktrees count.
if [ -d "$CODE_ROOT" ]; then
    echo -e "${YELLOW}Clearing: deps/build output in worktrees untouched for ${STALE_WORKTREE_DAYS}+ days${NC}"
    STALE_PRUNE=(-name .git -o -name node_modules -o -name .venv -o -name venv -o -name dist -o -name .expo -o -name .next -o -name .turbo -o -name build)
    while IFS= read -r gitfile; do
        grep -q '/worktrees/' "$gitfile" 2>/dev/null || continue
        wt=$(dirname "$gitfile")
        [ -z "$(find "$wt" \( "${STALE_PRUNE[@]}" \) -prune -o -type f -mtime "-${STALE_WORKTREE_DAYS}" -print -quit 2>/dev/null)" ] || continue
        while IFS= read -r dir; do
            git -C "$wt" check-ignore -q "$dir" 2>/dev/null || continue
            size_kb=$(get_size_bytes "$dir")
            rm -rf "$dir"
            TOTAL_FREED_KB=$((TOTAL_FREED_KB + size_kb))
            echo -e "${GREEN}  ✓ Removed $dir ($((size_kb / 1024))MB)${NC}"
        done < <(find "$wt" -maxdepth 4 -name .git -prune -o -type d \
            \( -name node_modules -o -name .venv -o -name venv -o -name dist -o -name build -o -name .expo -o -name .next \) -print -prune 2>/dev/null)
    done < <(find "$CODE_ROOT" -maxdepth 5 -name .git -type f 2>/dev/null)
    echo ""
fi

# Jest and Metro/haste-map caches live in $TMPDIR, not in the repo (same as `expo start -c`)
echo -e "${YELLOW}Clearing: Jest / Metro / haste-map caches in \$TMPDIR${NC}"
for tmp_cache in "${TMPDIR:-/tmp}"/jest_* "${TMPDIR:-/tmp}"/metro-* "${TMPDIR:-/tmp}"/haste-map-*; do
    [ -e "$tmp_cache" ] || continue
    size_kb=$(du -sk "$tmp_cache" 2>/dev/null | awk '{print $1}')
    rm -rf "$tmp_cache"
    TOTAL_FREED_KB=$((TOTAL_FREED_KB + ${size_kb:-0}))
    echo -e "${GREEN}  ✓ Removed $tmp_cache ($((${size_kb:-0} / 1024))MB)${NC}"
done
echo ""

# npm cache (if exists)
if command -v npm &> /dev/null; then
    # `npm cache clean` doesn't touch npx's package installs
    clear_cache "$HOME/.npm/_npx" "npx cache"
    echo -e "${YELLOW}Clearing: npm cache${NC}"
    npm cache clean --force 2>/dev/null || true
    echo -e "${GREEN}  ✓ npm cache cleared${NC}"
    echo ""
fi

# pip cache (if exists)
if command -v pip &> /dev/null; then
    echo -e "${YELLOW}Clearing: pip cache${NC}"
    pip cache purge 2>/dev/null || true
    echo -e "${GREEN}  ✓ pip cache cleared${NC}"
    echo ""
fi

# uv cache (if exists)
if command -v uv &> /dev/null; then
    echo -e "${YELLOW}Clearing: uv cache${NC}"
    uv cache clean 2>/dev/null || true
    echo -e "${GREEN}  ✓ uv cache cleared${NC}"
    echo ""
fi

# pnpm store (if exists) — only removes packages no longer referenced by any
# project's lockfile; worst case is a slower re-download on next install, no data loss
if command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}Clearing: pnpm store (unreferenced packages)${NC}"
    pnpm store prune 2>/dev/null || true
    echo -e "${GREEN}  ✓ pnpm store pruned${NC}"
    echo ""
fi

# pre-commit hook envs — gc only drops envs no longer referenced by any known repo config
if command -v pre-commit &> /dev/null; then
    size_before=$(get_size_bytes "$HOME/.cache/pre-commit")
    echo -e "${YELLOW}Clearing: pre-commit unused hook envs${NC}"
    pre-commit gc 2>/dev/null || true
    size_freed=$((size_before - $(get_size_bytes "$HOME/.cache/pre-commit")))
    [ "$size_freed" -gt 0 ] && TOTAL_FREED_KB=$((TOTAL_FREED_KB + size_freed))
    echo -e "${GREEN}  ✓ Freed: $((size_freed / 1024))MB${NC}"
    echo ""
fi

# Homebrew cache (if exists)
if command -v brew &> /dev/null; then
    echo -e "${YELLOW}Clearing: Homebrew cache${NC}"
    brew cleanup --prune=all || true
    echo -e "${GREEN}  ✓ Homebrew cache cleared${NC}"
    echo ""

    # Truncate (not delete) so running services keep writing to the same file.
    # A crash-looping service (e.g. php-fpm failing to bind its port) can grow its log to GBs.
    while IFS= read -r -d '' log; do
        size_kb=$(du -sk "$log" 2>/dev/null | awk '{print $1}')
        : > "$log"
        TOTAL_FREED_KB=$((TOTAL_FREED_KB + ${size_kb:-0}))
        echo -e "${GREEN}  ✓ Truncated $log (freed $((${size_kb:-0} / 1024))MB)${NC}"
    done < <(find "$(brew --prefix)/var/log" -maxdepth 2 -type f -size +100M -print0 2>/dev/null)
    echo ""
fi

# Docker cache (if Docker is running)
# "docker info" gathers metadata from every installed CLI plugin (e.g. docker-ai /
# "Ask Gordon") and has no built-in timeout, so a stuck plugin hangs it forever.
# Bound it with timeout so a broken plugin can't stall the whole script.
if command -v docker &> /dev/null && timeout 5 docker info &>/dev/null; then
    # Images and build cache are regenerable (re-pull/re-build), safe to auto-prune.
    # Volumes are NOT included here — they can hold real data (dev databases, etc.)
    # for a project that's just not running right now. See the confirmation prompt below.
    echo -e "${YELLOW}Clearing: Docker images and build cache${NC}"
    docker system prune -af || true
    echo -e "${GREEN}  ✓ Docker images/build cache cleared${NC}"
    echo ""

    # Unused volumes (not attached to any container, LINKS = 0): list + confirm before deleting
    unused_volumes=()
    unused_volume_sizes=()
    while IFS=$'\t' read -r vname vlinks vsize; do
        [ "$vlinks" = "0" ] || continue
        unused_volumes+=("$vname")
        unused_volume_sizes+=("$vsize")
    done < <(timeout 15 docker system df -v 2>/dev/null | awk '/^VOLUME NAME/{f=1;next} /^$/{f=0} f{print $1"\t"$2"\t"$3}')

    if [ "${#unused_volumes[@]}" -gt 0 ]; then
        echo -e "${RED}⚠️  Unused Docker volumes (no attached container)${NC}"
        echo -e "${YELLOW}These may hold real data (dev databases, uploads, etc.) for a stopped project.${NC}"
        for i in "${!unused_volumes[@]}"; do
            echo "  $((i+1)). ${unused_volumes[$i]} (${unused_volume_sizes[$i]})"
        done
        echo ""
        read -p "Delete all ${#unused_volumes[@]} unused volumes now? [y/N] " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            for vname in "${unused_volumes[@]}"; do
                docker volume rm "$vname" &>/dev/null || true
            done
            echo -e "${GREEN}  ✓ Deleted ${#unused_volumes[@]} unused volume(s)${NC}"
        else
            echo -e "${YELLOW}  Skipped. Run 'docker volume rm <name>' manually if desired.${NC}"
        fi
        echo ""
    fi
fi

# VS Code caches (if exists)
VSCODE_DIR="$HOME/Library/Application Support/Code"
if [ -d "$VSCODE_DIR" ]; then
    if pgrep -f "Visual Studio Code" > /dev/null; then
        echo -e "${YELLOW}⚠️  VS Code appears to be running. Cache clearing may be incomplete.${NC}"
        echo ""
    fi
    clear_cache "$VSCODE_DIR/Cache" "VS Code Cache"
    clear_cache "$VSCODE_DIR/CachedData" "VS Code CachedData"
    clear_cache "$VSCODE_DIR/CachedExtensionVSIXs" "VS Code Extension Cache"
    clear_cache "$VSCODE_DIR/logs" "VS Code Logs"
    clear_cache "$VSCODE_DIR/Code Cache" "VS Code Code Cache"
    clear_cache "$VSCODE_DIR/GPUCache" "VS Code GPU Cache"
    clear_cache "$VSCODE_DIR/WebStorage" "VS Code Web Storage"
    clear_cache "$VSCODE_DIR/Crashpad" "VS Code Crash Reports"
    clear_cache "$VSCODE_DIR/Partitions" "VS Code Partitions Cache"
    prune_workspace_storage "$VSCODE_DIR/User/workspaceStorage" "VS Code"
    echo -e "${GREEN}  ✓ VS Code caches cleared${NC}"
    echo ""
fi

# Cursor IDE caches (if exists)
CURSOR_DIR="$HOME/Library/Application Support/Cursor"
if [ -d "$CURSOR_DIR" ]; then
    # Check if Cursor is running
    if pgrep -f "Cursor" > /dev/null; then
        echo -e "${YELLOW}⚠️  Cursor appears to be running. Cache clearing may be incomplete.${NC}"
        echo -e "${YELLOW}    Consider closing Cursor before running this script for best results.${NC}"
        echo ""
    fi

    echo -e "${YELLOW}Clearing: Cursor IDE caches${NC}"

    # Safe cache directories to clear
    clear_cache "$CURSOR_DIR/CachedData" "Cursor CachedData"
    clear_cache "$CURSOR_DIR/Cache" "Cursor Cache"
    clear_cache "$CURSOR_DIR/CachedExtensionVSIXs" "Cursor Extension Cache"
    clear_cache "$CURSOR_DIR/GPUCache" "Cursor GPU Cache"
    clear_cache "$CURSOR_DIR/Code Cache" "Cursor Code Cache"
    clear_cache "$CURSOR_DIR/WebStorage" "Cursor Web Storage"
    clear_cache "$CURSOR_DIR/logs" "Cursor Logs"

    # Also check ~/Library/Caches for Cursor
    if [ -d "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92" ]; then
        clear_cache "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92" "Cursor System Cache"
    fi

    # Cursor globalStorage state DB (resets workspace/UI state; can grow large)
    CURSOR_GLOBAL_STATE="$CURSOR_DIR/User/globalStorage"
    if [ -d "$CURSOR_GLOBAL_STATE" ] && compgen -G "$CURSOR_GLOBAL_STATE/state.vscdb*" > /dev/null 2>&1; then
        size_before=0
        for f in "$CURSOR_GLOBAL_STATE"/state.vscdb*; do
            if [ -e "$f" ]; then
                s=$(du -sk "$f" 2>/dev/null | awk '{print $1}')
                size_before=$((size_before + ${s:-0}))
            fi
        done
        rm -f "$CURSOR_GLOBAL_STATE"/state.vscdb* 2>/dev/null || true
        echo -e "${YELLOW}Clearing: Cursor state DB (globalStorage)${NC}"
        echo "  Location: $CURSOR_GLOBAL_STATE/state.vscdb*"
        if [ "$size_before" -gt 0 ]; then
            TOTAL_FREED_KB=$((TOTAL_FREED_KB + size_before))
            echo -e "${GREEN}  ✓ Freed: $((size_before / 1024))MB${NC}"
        else
            echo -e "${GREEN}  ✓ Removed${NC}"
        fi
        echo ""
    fi

    # Cursor Dawn GPU caches
    clear_cache "$CURSOR_DIR/DawnWebGPUCache" "Cursor DawnWebGPU Cache"
    clear_cache "$CURSOR_DIR/DawnGraphiteCache" "Cursor DawnGraphite Cache"
    clear_cache "$CURSOR_DIR/Partitions" "Cursor Partitions Cache"

    prune_workspace_storage "$CURSOR_DIR/User/workspaceStorage" "Cursor"

    echo -e "${GREEN}  ✓ Cursor caches cleared${NC}"
    echo ""
fi

# Claude app caches
CLAUDE_DIR="$HOME/Library/Application Support/Claude"
if [ -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}Clearing: Claude app caches${NC}"
    clear_cache "$CLAUDE_DIR/Cache" "Claude Cache"
    clear_cache "$CLAUDE_DIR/Code Cache" "Claude Code Cache"
    clear_cache "$CLAUDE_DIR/GPUCache" "Claude GPU Cache"
    clear_cache "$CLAUDE_DIR/DawnWebGPUCache" "Claude DawnWebGPU Cache"
    clear_cache "$CLAUDE_DIR/DawnGraphiteCache" "Claude DawnGraphite Cache"
    echo -e "${GREEN}  ✓ Claude caches cleared${NC}"
    echo ""
fi

# Claude Code scratch space
clear_cache "/private/tmp/claude-scratch" "Claude Code Scratch"

# Claude Code local caches (safe/regenerable: undo history, telemetry, paste buffer, shell snapshots, debug logs)
clear_cache "$HOME/.claude/file-history" "Claude Code File History (undo backups)"
clear_cache "$HOME/.claude/telemetry" "Claude Code Telemetry"
clear_cache "$HOME/.claude/cache" "Claude Code Cache"
clear_cache "$HOME/.claude/paste-cache" "Claude Code Paste Cache"
clear_cache "$HOME/.claude/shell-snapshots" "Claude Code Shell Snapshots"
clear_cache "$HOME/.claude/debug" "Claude Code Debug Logs"

# Detect Claude Code project transcripts (~/.claude/projects) whose source repo is
# gone. Not cleared above: these hold real conversation history and any saved memory
# notes for a project, so deletion is deferred to the final alert + confirmation below.
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
orphan_dirs=()
orphan_sources=()
if [ -d "$CLAUDE_PROJECTS_DIR" ]; then
    for proj_dir in "$CLAUDE_PROJECTS_DIR"/*/; do
        [ -d "$proj_dir" ] || continue
        # Read the real source directory from a transcript's "cwd" field
        # (folder names have "-" escaped from "/", which is ambiguous to reverse
        # since real paths also contain literal hyphens).
        sample_jsonl=$(find "$proj_dir" -maxdepth 1 -name "*.jsonl" | head -1)
        [ -n "$sample_jsonl" ] || continue
        source_path=$(grep -o '"cwd":"[^"]*"' "$sample_jsonl" | head -1 | sed 's/"cwd":"//;s/"//')
        if [ -n "$source_path" ] && [ ! -d "$source_path" ]; then
            orphan_dirs+=("$proj_dir")
            orphan_sources+=("$source_path")
        fi
    done
fi

# Stremio server cache (if exists)
clear_cache "$HOME/Library/Application Support/stremio-server" "Stremio Server"

# Empty Trash
trash_size_kb=$(get_size_bytes "$HOME/.Trash")
echo -e "${YELLOW}Emptying Trash...${NC}"
rm -rf ~/.Trash/* 2>/dev/null || true
if [ "$trash_size_kb" -gt 0 ]; then
    TOTAL_FREED_KB=$((TOTAL_FREED_KB + trash_size_kb))
fi
echo -e "${GREEN}  ✓ Trash emptied${NC}"
echo ""

# Final alert: orphaned Claude Code project transcripts (source repo no longer exists)
if [ "${#orphan_dirs[@]}" -gt 0 ]; then
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}⚠️  Orphaned Claude Code project transcripts${NC}"
    echo -e "${RED}========================================${NC}"
    echo -e "${YELLOW}These transcript folders reference a source repo that no longer exists.${NC}"
    echo -e "${YELLOW}They may contain saved memory notes — review before deleting.${NC}"
    echo ""
    total_kb=0
    for i in "${!orphan_dirs[@]}"; do
        size=$(get_size "${orphan_dirs[$i]}")
        size_kb=$(get_size_bytes "${orphan_dirs[$i]}")
        total_kb=$((total_kb + size_kb))
        echo "  $((i+1)). ${orphan_dirs[$i]} ($size) -> was ${orphan_sources[$i]}"
    done
    echo ""
    echo -e "${YELLOW}Total: $((total_kb / 1024))MB across ${#orphan_dirs[@]} folder(s)${NC}"
    echo ""
    read -p "Delete all of these now? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        for proj_dir in "${orphan_dirs[@]}"; do
            rm -rf "$proj_dir"
        done
        TOTAL_FREED_KB=$((TOTAL_FREED_KB + total_kb))
        echo -e "${GREEN}  ✓ Deleted ${#orphan_dirs[@]} orphaned project folder(s)${NC}"
    else
        echo -e "${YELLOW}  Skipped. Delete manually later with 'rm -rf <path>' if desired.${NC}"
    fi
    echo ""
fi

# Final alert: Claude Code conversation transcripts older than CLAUDE_CONV_PURGE_DAYS.
# Only *.jsonl transcript files are listed/removed — memory/*.md notes are never touched
# since they're a different file type living alongside the transcripts.
old_convs=()
if [ -d "$CLAUDE_PROJECTS_DIR" ]; then
    while IFS= read -r -d '' f; do
        old_convs+=("$f")
    done < <(find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -mtime "+${CLAUDE_CONV_PURGE_DAYS}" -print0 2>/dev/null)
fi

if [ "${#old_convs[@]}" -gt 0 ]; then
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}⚠️  Claude Code conversations older than ${CLAUDE_CONV_PURGE_DAYS} days${NC}"
    echo -e "${RED}========================================${NC}"
    echo -e "${YELLOW}These are session transcripts, not memory notes (memory/*.md is never touched).${NC}"
    echo -e "${YELLOW}Deleting them removes the ability to --resume those sessions.${NC}"
    echo ""
    total_kb=0
    for f in "${old_convs[@]}"; do
        size_kb=$(du -sk "$f" 2>/dev/null | awk '{print $1}')
        total_kb=$((total_kb + ${size_kb:-0}))
    done
    echo -e "${YELLOW}Total: $((total_kb / 1024))MB across ${#old_convs[@]} conversation(s)${NC}"
    echo ""
    read -p "Delete all of these now? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        for f in "${old_convs[@]}"; do
            rm -f "$f"
        done
        TOTAL_FREED_KB=$((TOTAL_FREED_KB + total_kb))
        echo -e "${GREEN}  ✓ Deleted ${#old_convs[@]} conversation transcript(s)${NC}"
    else
        echo -e "${YELLOW}  Skipped. Adjust CLAUDE_CONV_PURGE_DAYS at the top of the script to change the threshold.${NC}"
    fi
    echo ""
fi

# Final summary — printed after every step (including the interactive orphan/old-conversation
# purges above) so it reflects everything that actually happened, not just the automatic part.
final_free=$(df -k / | tail -1 | awk '{print $4}')
space_freed_df=$((final_free - initial_free))

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Final disk space:${NC}"
df -h / | tail -1
echo ""

if [ "$TOTAL_FREED_KB" -gt 0 ]; then
    total_freed_mb=$((TOTAL_FREED_KB / 1024))
    if [ "$total_freed_mb" -gt 1024 ]; then
        total_freed_gb=$(echo "scale=2; $TOTAL_FREED_KB / 1048576" | bc)
        echo -e "${GREEN}Total space freed: ${total_freed_gb}GB${NC}"
    else
        echo -e "${GREEN}Total space freed: ${total_freed_mb}MB${NC}"
    fi
else
    echo -e "${GREEN}Nothing to clean — caches were already empty${NC}"
fi

# `df`'s free-space delta can lag behind (or diverge from) the tracked total above:
# APFS reclaims deleted blocks as "purgeable" space asynchronously, not instantly.
# This script never needs sudo — everything it touches is user-owned — so a gap here
# is reporting lag, not a permissions issue.
if [ "$TOTAL_FREED_KB" -gt 0 ] && [ $((TOTAL_FREED_KB - space_freed_df)) -gt $((512 * 1024)) ]; then
    echo -e "${YELLOW}Note: reported free disk space hasn't fully caught up yet — APFS reclaims purgeable space asynchronously and it should settle within a few minutes.${NC}"
fi
echo ""

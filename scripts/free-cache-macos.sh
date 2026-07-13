#!/bin/bash

# Script to free up cache space on macOS
# This script safely clears various cache directories

set -e

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
        du -sk "$1" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

# Function to clear cache directory
# Optional third arg: name of an entry directly under cache_dir to skip (e.g. a cache
# that's expensive to redownload, like Playwright's browser binaries).
clear_cache() {
    local cache_dir=$1
    local description=$2
    local exclude=$3

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
    if [ -n "$exclude" ]; then
        find "$cache_dir" -mindepth 1 -maxdepth 1 ! -name "$exclude" -exec rm -rf {} + 2>/dev/null || true
    else
        find "$cache_dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    fi

    local size_after=$(get_size_bytes "$cache_dir")
    local size_freed=$((size_before - size_after))
    local size_freed_mb=$((size_freed / 1024))

    if [ $size_freed_mb -gt 0 ]; then
        echo -e "${GREEN}  ✓ Freed: ${size_freed_mb}MB${NC}"
    else
        echo -e "${GREEN}  ✓ Already clean${NC}"
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

# User caches (keep ms-playwright — browser binaries are slow/flaky to redownload)
clear_cache "$HOME/Library/Caches" "User Library Caches" "ms-playwright"

# Browser caches (optional - uncomment if needed)
# clear_cache "$HOME/Library/Caches/Google/Chrome" "Chrome Cache"
# clear_cache "$HOME/Library/Caches/com.apple.Safari" "Safari Cache"
# clear_cache "$HOME/Library/Caches/com.mozilla.firefox" "Firefox Cache"

# Google Chrome caches
clear_cache "$HOME/Library/Application Support/Google/Chrome/Default/Cache" "Chrome Cache"
clear_cache "$HOME/Library/Application Support/Google/Chrome/Default/Code Cache" "Chrome Code Cache"
clear_cache "$HOME/Library/Application Support/Google/Chrome/Default/GPUCache" "Chrome GPU Cache"
clear_cache "$HOME/Library/Application Support/Google/GoogleUpdater/crx_cache" "Google Updater crx_cache"

# Xcode derived data (if exists)
clear_cache "$HOME/Library/Developer/Xcode/DerivedData" "Xcode Derived Data"

# Xcode archives (if exists)
clear_cache "$HOME/Library/Developer/Xcode/Archives" "Xcode Archives"

# npm cache (if exists)
if command -v npm &> /dev/null; then
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

# Homebrew cache (if exists)
if command -v brew &> /dev/null; then
    echo -e "${YELLOW}Clearing: Homebrew cache${NC}"
    brew cleanup --prune=all || true
    echo -e "${GREEN}  ✓ Homebrew cache cleared${NC}"
    echo ""
fi

# Docker cache (if Docker is running)
if command -v docker &> /dev/null && docker info &>/dev/null; then
    echo -e "${YELLOW}Clearing: Docker system cache${NC}"
    docker system prune -af --volumes || true
    echo -e "${GREEN}  ✓ Docker cache cleared${NC}"
    echo ""
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

    # Prune workspaceStorage for workspaces that no longer exist on disk
    WORKSPACE_STORAGE="$CURSOR_DIR/User/workspaceStorage"
    if [ -d "$WORKSPACE_STORAGE" ]; then
        echo -e "${YELLOW}Pruning: Cursor workspaceStorage (orphaned workspaces)${NC}"
        pruned=0
        for ws_dir in "$WORKSPACE_STORAGE"/*/; do
            workspace_json="$ws_dir/workspace.json"
            if [ ! -f "$workspace_json" ]; then
                continue
            fi
            folder=$(grep -o '"folder":"[^"]*"' "$workspace_json" 2>/dev/null | head -1 | sed 's/"folder":"//;s/"//' | sed 's|^file://||')
            if [ -n "$folder" ] && [ ! -d "$folder" ]; then
                size_kb=$(du -sk "$ws_dir" 2>/dev/null | awk '{print $1}')
                rm -rf "$ws_dir"
                pruned=$((pruned + size_kb))
            fi
        done
        if [ "$pruned" -gt 0 ]; then
            echo -e "${GREEN}  ✓ Freed: $((pruned / 1024))MB (orphaned workspaces)${NC}"
        else
            echo -e "${GREEN}  ✓ No orphaned workspaces found${NC}"
        fi
        echo ""
    fi

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

# Stremio server cache (if exists)
clear_cache "$HOME/Library/Application Support/stremio-server" "Stremio Server"

# Empty Trash
echo -e "${YELLOW}Emptying Trash...${NC}"
rm -rf ~/.Trash/* 2>/dev/null || true
echo -e "${GREEN}  ✓ Trash emptied${NC}"
echo ""

# Get final free space
final_free=$(df -k / | tail -1 | awk '{print $4}')
space_freed=$((final_free - initial_free))
space_freed_mb=$((space_freed / 1024))
space_freed_gb=$(echo "scale=2; $space_freed / 1048576" | bc)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Final disk space:${NC}"
df -h / | tail -1
echo ""

if [ $space_freed_mb -gt 0 ]; then
    if [ $space_freed_mb -gt 1024 ]; then
        echo -e "${GREEN}Total space freed: ${space_freed_gb}GB${NC}"
    else
        echo -e "${GREEN}Total space freed: ${space_freed_mb}MB${NC}"
    fi
else
    echo -e "${YELLOW}No significant space was freed (may need admin privileges for system caches)${NC}"
fi
echo ""

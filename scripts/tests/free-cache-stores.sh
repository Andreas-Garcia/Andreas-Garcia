#!/bin/bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/home"
export HOME="$fixture/home" TEST_LOG="$fixture/commands.log"
export COREPACK_HOME="$fixture/corepack cache"
export TEST_STORE="$fixture/pnpm store/v11"
unset XDG_CACHE_HOME LOCALAPPDATA

for tool in du awk find rm; do
    ln -s "$(command -v "$tool")" "$fixture/bin/$tool"
done
cat > "$fixture/bin/pip3" <<'MOCK'
#!/bin/sh
echo "${0##*/} $*" >> "$TEST_LOG"
exit "${TEST_PIP_STATUS:-0}"
MOCK
cat > "$fixture/bin/pnpm" <<'MOCK'
#!/bin/sh
case "$*" in
    'store path') printf '%s\n' "$TEST_STORE" ;;
    'store prune') echo 'pnpm store prune' >> "$TEST_LOG"; exit "${TEST_PRUNE_STATUS:-0}" ;;
    *) exit 99 ;;
esac
MOCK
chmod +x "$fixture/bin/pip3" "$fixture/bin/pnpm"

# Execute the production helpers and package-store sections without running the
# unrelated machine-wide cleanup operations.
sed '/^# Prune VS Code-style/,$d' "$repo_root/scripts/free-cache-macos.sh" > "$fixture/cleanup.sh"
sed -n '/^# pip cache (if exists)/,/^# uv cache (if exists)/{ /^# uv cache (if exists)/!p; }' \
    "$repo_root/scripts/free-cache-macos.sh" >> "$fixture/cleanup.sh"
sed -n '/^# pnpm store (if exists)/,/^# pre-commit hook envs/{ /^# pre-commit hook envs/!p; }' \
    "$repo_root/scripts/free-cache-macos.sh" >> "$fixture/cleanup.sh"

for version in v9 v10 v11 v12 v10-backup; do
    mkdir -p "${TEST_STORE%/*}/$version"
    echo package > "${TEST_STORE%/*}/$version/package"
done
mkdir -p "$COREPACK_HOME/v1" "$COREPACK_HOME/v2" "$fixture/external"
echo download > "$COREPACK_HOME/v1/package"
echo download > "$COREPACK_HOME/v2/package"
echo keep > "$fixture/external/package"
echo '{}' > "$COREPACK_HOME/lastKnownGood.json"
ln -s "$fixture/external" "$COREPACK_HOME/v3"
ln -s "$fixture/external" "${TEST_STORE%/*}/v8"

run_cleanup() {
    PATH="$fixture/bin" /bin/bash "$fixture/cleanup.sh" "$@" > "$fixture/output.log" 2>&1
}

run_cleanup --dry-run
test ! -e "$TEST_LOG"
test -f "${TEST_STORE%/*}/v10/package"
test -f "$COREPACK_HOME/v1/package"
grep -q 'pnpm older store (v10)' "$fixture/output.log"
grep -q 'Corepack package-manager downloads (v1)' "$fixture/output.log"

if TEST_PIP_STATUS=2 run_cleanup; then echo 'pip failure was ignored' >&2; exit 1; fi
if TEST_PRUNE_STATUS=2 run_cleanup; then echo 'pnpm failure was ignored' >&2; exit 1; fi
if TEST_STORE="$fixture/unexpected" run_cleanup; then echo 'invalid store accepted' >&2; exit 1; fi
test -f "${TEST_STORE%/*}/v10/package"

rm -f "$TEST_LOG"
run_cleanup
grep -q '^pip3 cache purge$' "$TEST_LOG"
grep -q '^pnpm store prune$' "$TEST_LOG"
for version in v9 v10; do test ! -e "${TEST_STORE%/*}/$version/package"; done
for version in v11 v12 v10-backup; do test -f "${TEST_STORE%/*}/$version/package"; done
test ! -e "$COREPACK_HOME/v1/package"
test ! -e "$COREPACK_HOME/v2/package"
test -f "$COREPACK_HOME/lastKnownGood.json"
test -f "$fixture/external/package"

cp "$fixture/bin/pip3" "$fixture/bin/pip"
rm -f "$TEST_LOG"
run_cleanup
grep -q '^pip cache purge$' "$TEST_LOG"
if grep -q '^pip3 ' "$TEST_LOG"; then echo 'pip3 used despite pip being available' >&2; exit 1; fi

rm "$fixture/bin/pip" "$fixture/bin/pip3"
unset COREPACK_HOME
export XDG_CACHE_HOME="$fixture/xdg"
mkdir -p "$XDG_CACHE_HOME/node/corepack/v1"
echo cache > "$XDG_CACHE_HOME/node/corepack/v1/package"
run_cleanup
test ! -e "$XDG_CACHE_HOME/node/corepack/v1/package"
unset XDG_CACHE_HOME
mkdir -p "$HOME/.cache/node/corepack/v1"
echo cache > "$HOME/.cache/node/corepack/v1/package"
run_cleanup
test ! -e "$HOME/.cache/node/corepack/v1/package"
if COREPACK_HOME=/ run_cleanup; then echo 'unsafe Corepack root accepted' >&2; exit 1; fi

echo 'Package-store cleanup regression checks passed.'

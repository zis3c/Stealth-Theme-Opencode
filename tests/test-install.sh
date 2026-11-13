#!/usr/bin/env bash
# Tests for install.sh / uninstall.sh on Linux, macOS and Windows (Git Bash).
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PY="$(command -v python3 || command -v python || true)"
if [ -z "$PY" ]; then
  echo "python3 or python is required to run these tests" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_json() {
  local file="$1"
  shift
  "$PY" - "$file" "$@" <<'PY'
import json
import sys

path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
for expr in sys.argv[2:]:
    # expr like "theme=stealth" or "theme.name=stealth" or "keybinds.leader=ctrl+x"
    key, _, expected = expr.partition("=")
    cur = data
    for part in key.split("."):
        cur = cur[part]
    assert str(cur) == expected, f"{key}: expected {expected!r}, got {cur!r} ({path})"
PY
}

# --- Case 1: existing tui.json keeps unrelated settings (default gray) ----
mkdir -p "$TMP/case1"
printf '%s\n' '{"$schema":"https://opencode.ai/tui.json","theme":"opencode","keybinds":{"leader":"ctrl+x"}}' \
  > "$TMP/case1/tui.json"

OPENCODE_CONFIG_DIR="$TMP/case1" "$ROOT/install.sh" >/dev/null
[ -f "$TMP/case1/themes/stealth.json" ] || fail "theme not installed"
assert_json "$TMP/case1/tui.json" "theme=stealth" "keybinds.leader=ctrl+x"

OPENCODE_CONFIG_DIR="$TMP/case1" "$ROOT/uninstall.sh" >/dev/null
[ ! -f "$TMP/case1/themes/stealth.json" ] || fail "theme not removed"
assert_json "$TMP/case1/tui.json" "theme=opencode" "keybinds.leader=ctrl+x"

# --- Case 2: fresh config directory --------------------------------------
mkdir -p "$TMP/case2"
OPENCODE_CONFIG_DIR="$TMP/case2" "$ROOT/install.sh" >/dev/null
[ -f "$TMP/case2/themes/stealth.json" ] || fail "theme not installed (fresh)"
[ -f "$TMP/case2/tui.json" ] || fail "tui.json not created (fresh)"
assert_json "$TMP/case2/tui.json" "theme=stealth" '$schema=https://opencode.ai/tui.json'

# --- Case 3: variant theme ------------------------------------------------
mkdir -p "$TMP/case3"
OPENCODE_CONFIG_DIR="$TMP/case3" "$ROOT/install.sh" --variant amber >/dev/null
[ -f "$TMP/case3/themes/stealth-amber.json" ] || fail "amber variant not installed"
assert_json "$TMP/case3/tui.json" "theme=stealth-amber"
OPENCODE_CONFIG_DIR="$TMP/case3" "$ROOT/uninstall.sh" --variant amber >/dev/null
[ ! -f "$TMP/case3/themes/stealth-amber.json" ] || fail "amber variant not removed"
assert_json "$TMP/case3/tui.json" "theme=opencode"

# --- Case 4: v2 cli.json auto-detection ----------------------------------
mkdir -p "$TMP/case4"
printf '%s\n' '{"$schema":"https://opencode.ai/v2/cli.json","model":"x","theme":{"name":"opencode","mode":"dark"}}' \
  > "$TMP/case4/cli.json"
OPENCODE_CONFIG_DIR="$TMP/case4" "$ROOT/install.sh" >/dev/null
[ ! -f "$TMP/case4/tui.json" ] || fail "tui.json should not be created in v2 mode"
assert_json "$TMP/case4/cli.json" "theme.name=stealth" "theme.mode=dark" "model=x"
OPENCODE_CONFIG_DIR="$TMP/case4" "$ROOT/uninstall.sh" >/dev/null
assert_json "$TMP/case4/cli.json" "theme.name=opencode" "theme.mode=dark"

# --- Case 5: explicit --v2 on a fresh directory --------------------------
mkdir -p "$TMP/case5"
OPENCODE_CONFIG_DIR="$TMP/case5" "$ROOT/install.sh" --v2 --variant green >/dev/null
[ -f "$TMP/case5/themes/stealth-green.json" ] || fail "green variant not installed (v2)"
assert_json "$TMP/case5/cli.json" "theme.name=stealth-green" "theme.mode=system"
OPENCODE_CONFIG_DIR="$TMP/case5" "$ROOT/uninstall.sh" --v2 --variant green >/dev/null
[ ! -f "$TMP/case5/themes/stealth-green.json" ] || fail "green variant not removed (v2)"

echo "shell installer tests passed"

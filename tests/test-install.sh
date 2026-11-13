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

# --- Case 1: existing tui.json keeps unrelated settings -------------------
mkdir -p "$TMP/case1"
printf '%s\n' '{"$schema":"https://opencode.ai/tui.json","theme":"opencode","keybinds":{"leader":"ctrl+x"}}' \
  > "$TMP/case1/tui.json"

OPENCODE_CONFIG_DIR="$TMP/case1" "$ROOT/install.sh" >/dev/null
[ -f "$TMP/case1/themes/stealth.json" ] || fail "theme not installed"

"$PY" - "$TMP/case1/tui.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["theme"] == "stealth", data
assert data["keybinds"]["leader"] == "ctrl+x", data
PY

OPENCODE_CONFIG_DIR="$TMP/case1" "$ROOT/uninstall.sh" >/dev/null
[ ! -f "$TMP/case1/themes/stealth.json" ] || fail "theme not removed"

"$PY" - "$TMP/case1/tui.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["theme"] == "opencode", data
assert data["keybinds"]["leader"] == "ctrl+x", data
PY

# --- Case 2: fresh config directory --------------------------------------
mkdir -p "$TMP/case2"
OPENCODE_CONFIG_DIR="$TMP/case2" "$ROOT/install.sh" >/dev/null
[ -f "$TMP/case2/themes/stealth.json" ] || fail "theme not installed (fresh dir)"
[ -f "$TMP/case2/tui.json" ] || fail "tui.json not created (fresh dir)"

"$PY" - "$TMP/case2/tui.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["theme"] == "stealth", data
assert data["$schema"] == "https://opencode.ai/tui.json", data
PY

echo "shell installer tests passed"

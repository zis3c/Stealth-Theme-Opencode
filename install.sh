#!/usr/bin/env bash
set -Eeuo pipefail

# Install an opencode "stealth" theme on Linux and macOS.
# Also works from Git Bash / WSL on Windows (PowerShell users: use install.ps1).
#
# Usage:
#   ./install.sh [--variant gray|amber|green] [--v2]
#
# Copies the theme and sets it as the active theme while preserving any
# existing tui.json / cli.json settings.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"
THEME_DIR="$DEST/themes"
TUI="$DEST/tui.json"
CLI="$DEST/cli.json"

VARIANT="gray"
V2="${OPENCODE_V2:-0}"

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --variant gray|amber|green  Theme palette (default: gray)
  --v2                        Write opencode v2 cli.json instead of tui.json
  -h, --help                  Show this help

Environment:
  OPENCODE_CONFIG_DIR   Override the opencode config directory
  OPENCODE_V2=1         Same as --v2
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --variant)
      [ "$#" -ge 2 ] || { echo "--variant requires a value" >&2; exit 2; }
      VARIANT="$2"; shift 2 ;;
    --variant=*)
      VARIANT="${1#*=}"; shift ;;
    --v2)
      V2=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$VARIANT" in
  gray|stealth) THEME="stealth" ;;
  amber|green) THEME="stealth-$VARIANT" ;;
  *)
    echo "Unknown variant: $VARIANT (expected gray, amber or green)" >&2
    exit 2 ;;
esac

SRC="$SCRIPT_DIR/themes/$THEME.json"
[ -f "$SRC" ] || { echo "Theme file not found: $SRC" >&2; exit 1; }

mkdir -p "$THEME_DIR"
cp -f "$SRC" "$THEME_DIR/$THEME.json"
chmod 0644 "$THEME_DIR/$THEME.json" 2>/dev/null || true

find_python() {
  if command -v python3 >/dev/null 2>&1; then echo python3
  elif command -v python >/dev/null 2>&1; then echo python
  else echo ""
  fi
}

PY="$(find_python)"

# Use v2 when requested, or when a v2 cli.json exists and tui.json does not.
if [ "$V2" != "1" ] && [ -f "$CLI" ] && [ ! -f "$TUI" ]; then
  V2=1
fi

write_v1() {
  if [ -n "$PY" ]; then
    "$PY" - "$TUI" "$THEME" <<'PY'
import json
import os
import sys

path, theme = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    try:
        with open(path, "r", encoding="utf-8") as fh:
            data = json.load(fh)
    except (ValueError, OSError):
        data = {}
if not isinstance(data, dict):
    data = {}
data.setdefault("$schema", "https://opencode.ai/tui.json")
data["theme"] = theme
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
    return 0
  fi

  if command -v jq >/dev/null 2>&1; then
    if [ -f "$TUI" ]; then
      jq --arg t "$THEME" '. + {theme:$t} | if has("$schema") then . else . + {"$schema":"https://opencode.ai/tui.json"} end' \
        "$TUI" > "$TUI.tmp" && mv "$TUI.tmp" "$TUI"
    else
      printf '{\n  "$schema": "https://opencode.ai/tui.json",\n  "theme": "%s"\n}\n' "$THEME" > "$TUI"
    fi
    return 0
  fi

  if [ ! -f "$TUI" ]; then
    printf '{\n  "$schema": "https://opencode.ai/tui.json",\n  "theme": "%s"\n}\n' "$THEME" > "$TUI"
    return 0
  fi

  echo "No python3/python/jq found; leaving existing $TUI untouched." >&2
  echo "Set \"theme\": \"$THEME\" in $TUI manually." >&2
  return 1
}

write_v2() {
  if [ -n "$PY" ]; then
    "$PY" - "$CLI" "$THEME" <<'PY'
import json
import os
import sys

path, theme = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    try:
        with open(path, "r", encoding="utf-8") as fh:
            data = json.load(fh)
    except (ValueError, OSError):
        data = {}
if not isinstance(data, dict):
    data = {}

mode = "system"
existing = data.get("theme")
if isinstance(existing, dict) and existing.get("mode") in ("system", "dark", "light"):
    mode = existing["mode"]

data.setdefault("$schema", "https://opencode.ai/v2/cli.json")
data["theme"] = {"name": theme, "mode": mode}
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
    return 0
  fi

  echo "python3/python is required for opencode v2 cli.json installs." >&2
  echo "Add \"theme\": {\"name\": \"$THEME\", \"mode\": \"system\"} to $CLI manually." >&2
  return 1
}

if [ "$V2" = "1" ]; then
  write_v2
  CONFIG_FILE="$CLI"
else
  write_v1
  CONFIG_FILE="$TUI"
fi

echo "Installed $THEME theme to $THEME_DIR/$THEME.json"
echo "Active theme set in $CONFIG_FILE"
echo "Restart opencode to apply."

#!/usr/bin/env bash
set -Eeuo pipefail

# Install the "stealth" theme for opencode 1.x on Linux and macOS.
# Also works from Git Bash / WSL on Windows (PowerShell users: use install.ps1).
#
# Copies the theme and sets it as the active theme in tui.json while preserving
# any existing tui.json settings (keybinds, cursor, etc.).

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"
THEME_DIR="$DEST/themes"
TUI="$DEST/tui.json"

mkdir -p "$THEME_DIR"
cp -f "$SCRIPT_DIR/themes/stealth.json" "$THEME_DIR/stealth.json"
chmod 0644 "$THEME_DIR/stealth.json" 2>/dev/null || true

write_tui_json() {
  local py=""
  if command -v python3 >/dev/null 2>&1; then
    py="python3"
  elif command -v python >/dev/null 2>&1; then
    py="python"
  fi

  if [ -n "$py" ]; then
    "$py" - "$TUI" <<'PY'
import json
import os
import sys

path = sys.argv[1]
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
data["theme"] = "stealth"
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PY
    return 0
  fi

  if command -v jq >/dev/null 2>&1; then
    if [ -f "$TUI" ]; then
      jq '. + {theme:"stealth"} | if has("$schema") then . else . + {"$schema":"https://opencode.ai/tui.json"} end' \
        "$TUI" > "$TUI.tmp" && mv "$TUI.tmp" "$TUI"
    else
      printf '{\n  "$schema": "https://opencode.ai/tui.json",\n  "theme": "stealth"\n}\n' > "$TUI"
    fi
    return 0
  fi

  if [ ! -f "$TUI" ]; then
    printf '{\n  "$schema": "https://opencode.ai/tui.json",\n  "theme": "stealth"\n}\n' > "$TUI"
    return 0
  fi

  echo "No python3/python/jq found; leaving existing $TUI untouched." >&2
  echo "Set \"theme\": \"stealth\" in $TUI manually." >&2
  return 1
}

write_tui_json

echo "Installed stealth theme to $THEME_DIR/stealth.json"
echo "Active theme set in $TUI"
echo "Restart opencode to apply."

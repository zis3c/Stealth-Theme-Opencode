#!/usr/bin/env bash
set -Eeuo pipefail

# Install the "stealth" theme for opencode 1.x.
# Copies the theme and sets it as the active theme in tui.json while
# preserving any existing tui.json settings (keybinds, cursor, etc.).

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"
THEME_DIR="$DEST/themes"
TUI="$DEST/tui.json"

mkdir -p "$THEME_DIR"
install -m 0644 "$SCRIPT_DIR/themes/stealth.json" "$THEME_DIR/stealth.json"

if command -v python3 >/dev/null 2>&1; then
  python3 - "$TUI" <<'PY'
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
elif [ -f "$TUI" ]; then
  echo "python3 not found; leaving existing $TUI untouched." >&2
  echo "Set \"theme\": \"stealth\" in $TUI manually." >&2
else
  printf '{\n  "$schema": "https://opencode.ai/tui.json",\n  "theme": "stealth"\n}\n' > "$TUI"
fi

echo "Installed stealth theme to $THEME_DIR/stealth.json"
echo "Active theme set in $TUI"
echo "Restart opencode to apply."

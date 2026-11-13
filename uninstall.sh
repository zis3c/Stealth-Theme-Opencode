#!/usr/bin/env bash
set -Eeuo pipefail

# Remove the "stealth" theme (Linux/macOS). Restores opencode's default theme
# in tui.json if it currently points at stealth.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"
THEME_FILE="$DEST/themes/stealth.json"
TUI="$DEST/tui.json"

if [ -f "$THEME_FILE" ]; then
  rm -f "$THEME_FILE"
  echo "Removed $THEME_FILE"
else
  echo "Theme not installed at $THEME_FILE"
fi

if [ -f "$TUI" ]; then
  if command -v python3 >/dev/null 2>&1; then py=python3
  elif command -v python >/dev/null 2>&1; then py=python
  else py=""; fi

  if [ -n "$py" ]; then
    "$py" - "$TUI" <<'PY'
import json
import sys

path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as fh:
        data = json.load(fh)
except (ValueError, OSError):
    data = None
if isinstance(data, dict) and data.get("theme") == "stealth":
    data["theme"] = "opencode"
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)
        fh.write("\n")
    print(f"Restored default theme in {path}")
PY
  else
    echo "Set \"theme\": \"opencode\" in $TUI manually." >&2
  fi
fi

echo "Restart opencode to apply."

#!/usr/bin/env bash
set -Eeuo pipefail

# Remove an opencode stealth theme (Linux/macOS).
# Usage: ./uninstall.sh [--variant gray|amber|green] [--v2]

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"
TUI="$DEST/tui.json"
CLI="$DEST/cli.json"

VARIANT="gray"
V2="${OPENCODE_V2:-0}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --variant)
      [ "$#" -ge 2 ] || { echo "--variant requires a value" >&2; exit 2; }
      VARIANT="$2"; shift 2 ;;
    --variant=*) VARIANT="${1#*=}"; shift ;;
    --v2) V2=1; shift ;;
    -h|--help)
      echo "Usage: ./uninstall.sh [--variant gray|amber|green] [--v2]"
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

case "$VARIANT" in
  gray|stealth) THEME="stealth" ;;
  amber|green) THEME="stealth-$VARIANT" ;;
  *) echo "Unknown variant: $VARIANT" >&2; exit 2 ;;
esac

THEME_FILE="$DEST/themes/$THEME.json"
if [ -f "$THEME_FILE" ]; then
  rm -f "$THEME_FILE"
  echo "Removed $THEME_FILE"
else
  echo "Theme not installed at $THEME_FILE"
fi

if [ "$V2" != "1" ] && [ -f "$CLI" ] && [ ! -f "$TUI" ]; then
  V2=1
fi

restore_json() {
  local path="$1" kind="$2"
  if command -v python3 >/dev/null 2>&1; then py=python3
  elif command -v python >/dev/null 2>&1; then py=python
  else py=""; fi
  [ -n "$py" ] || return 1

  "$py" - "$path" "$kind" "$THEME" <<'PY'
import json
import sys

path, kind, theme = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(path, "r", encoding="utf-8") as fh:
        data = json.load(fh)
except (ValueError, OSError):
    raise SystemExit(0)
if not isinstance(data, dict):
    raise SystemExit(0)

changed = False
if kind == "v2":
    current = data.get("theme")
    name = current.get("name") if isinstance(current, dict) else current
    if name == theme:
        mode = current.get("mode", "system") if isinstance(current, dict) else "system"
        data["theme"] = {"name": "opencode", "mode": mode}
        changed = True
else:
    if data.get("theme") == theme:
        data["theme"] = "opencode"
        changed = True

if changed:
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)
        fh.write("\n")
    print(f"Restored default theme in {path}")
PY
}

if [ "$V2" = "1" ]; then
  if [ -f "$CLI" ]; then restore_json "$CLI" v2 || echo "Set \"theme\": {\"name\": \"opencode\"} in $CLI manually." >&2; fi
else
  if [ -f "$TUI" ]; then restore_json "$TUI" v1 || echo "Set \"theme\": \"opencode\" in $TUI manually." >&2; fi
fi

echo "Restart opencode to apply."

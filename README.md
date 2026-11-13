# opencode-stealth-theme

A low-key, monochrome [opencode](https://opencode.ai) TUI theme that blends into a
plain terminal. Transparent backgrounds, gray-only palette, no bright accents —
useful when you do not want the UI to stand out.

The theme is intentionally presentation-only: it does not change opencode's
harness, models, permissions, tools, or behavior.

## What you get

- `themes/stealth.json` — the theme (opencode 1.x `defs` + `theme` format).
- Transparent app/panel/input backgrounds so the terminal background shows through.
- Light and dark variants so the theme follows your terminal mode.
- Readable body text, muted secondary text.

## Requirements

- opencode 1.x (tested with 1.19.3).
- opencode reads TUI settings from `~/.config/opencode/tui.json` and custom themes
  from `~/.config/opencode/themes/*.json` in this version.
- Linux/macOS: `bash` (macOS default is fine) and one of `python3`, `python`, or `jq`.
- Windows: PowerShell 5.1+ (built in) or PowerShell 7.

> Newer opencode releases may use `cli.json` and a `{ "name", "mode" }` theme
> object. If your version differs, copy `themes/stealth.json` into the theme
> directory it documents and select `stealth`.

## Install

### Linux / macOS

```bash
git clone <your-fork-url> opencode-stealth-theme
cd opencode-stealth-theme
chmod +x install.sh
./install.sh
```

### Windows (PowerShell)

```powershell
git clone <your-fork-url> opencode-stealth-theme
cd opencode-stealth-theme
powershell -ExecutionPolicy Bypass -File .\install.ps1
# or, with PowerShell 7:
# pwsh -File .\install.ps1
```

### Windows (Git Bash / WSL)

```bash
./install.sh
```

The installer copies the theme and sets `"theme": "stealth"` in `tui.json`,
preserving any existing settings. Then restart opencode.

### Custom config location

All installers honor `OPENCODE_CONFIG_DIR`:

```bash
OPENCODE_CONFIG_DIR="$HOME/.config/opencode" ./install.sh
```

```powershell
$env:OPENCODE_CONFIG_DIR = "$HOME\.config\opencode"
.\install.ps1
```

The default is `${XDG_CONFIG_HOME:-$HOME/.config}/opencode`
(`%USERPROFILE%\.config\opencode` on Windows).

### Manual install

Create `<config>/themes/stealth.json` from `themes/stealth.json`, then create or
edit `<config>/tui.json`:

```json
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "stealth"
}
```

Paths by platform:

| Platform | Config directory |
| --- | --- |
| Linux / macOS | `~/.config/opencode` (or `$XDG_CONFIG_HOME/opencode`) |
| Windows | `%USERPROFILE%\.config\opencode` |

## Switching themes

- In the TUI: `Ctrl+P` → Theme → choose `stealth` or `opencode`.
- Or edit `tui.json`:
  - `"theme": "stealth"` for the plain look
  - `"theme": "opencode"` for the default theme

## Uninstall

Linux / macOS:

```bash
./uninstall.sh
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

Or manually delete `themes/stealth.json` and set `"theme": "opencode"`.

## Tuning

Edit the installed `themes/stealth.json`. Useful knobs:

| Token | Purpose |
| --- | --- |
| `darkMuted` / `lightMuted` | placeholder and secondary text |
| `darkFaint` / `lightFaint` | comments, faint text |
| `darkElement` / `lightElement` | input/selection surface (`transparent` = terminal bg) |
| `backgroundMenu` | menus and dialogs (kept slightly opaque for readability) |
| `primary` / `accent` | interactive highlights and headings |

Set `backgroundElement` to `"transparent"` to make the input box match your
terminal background exactly.

## License

MIT — see [LICENSE](LICENSE).

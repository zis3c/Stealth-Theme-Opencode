# Installation

## Prerequisites

- OpenCode installed (v1 or v2).
- Linux/macOS: `bash` and one of `python3`, `python` or `jq` (used to merge config).
- Windows: PowerShell 5.1+ (built in) or PowerShell 7.

The theme does not require root privileges and does not touch the OpenCode binary.

## Default config location

| Platform | Directory |
|---|---|
| Linux / macOS | `${XDG_CONFIG_HOME:-$HOME/.config}/opencode` |
| Windows | `%USERPROFILE%\.config\opencode` |

Override with `OPENCODE_CONFIG_DIR`.

## Install

### Linux / macOS

```bash
git clone https://github.com/zis3c/Stealth-Theme-Opencode.git
cd Stealth-Theme-Opencode
chmod +x install.sh
./install.sh
```

### Windows PowerShell

```powershell
git clone https://github.com/zis3c/Stealth-Theme-Opencode.git
cd Stealth-Theme-Opencode
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Or run `install.cmd` (double-click friendly).

### Windows Git Bash / WSL

```bash
./install.sh
```

## Options

| Option | Bash | PowerShell | Description |
|---|---|---|---|
| Variant | `--variant amber` | `-Variant amber` | `gray` (default), `amber`, `green` |
| OpenCode v2 | `--v2` | `-V2` | Write `cli.json` instead of `tui.json` |
| Config dir | `OPENCODE_CONFIG_DIR=...` | `-ConfigDir ...` | Override config directory |

The installer auto-detects v2 when `cli.json` exists and `tui.json` does not.

## What the installer changes

- Copies `themes/<theme>.json` into `<config>/themes/`.
- Sets the active theme:
  - v1: `"theme": "<theme>"` in `tui.json`.
  - v2: `"theme": { "name": "<theme>", "mode": "system" }` in `cli.json`.
- Preserves every other key already present in those files.

Themes are OpenCode 1.x (`defs` + `theme`) files. OpenCode v2 migrates V1 custom themes at
runtime, so the same theme file works for both.

## Manual installation

```bash
mkdir -p ~/.config/opencode/themes
cp themes/stealth.json ~/.config/opencode/themes/
```

v1 `~/.config/opencode/tui.json`:

```json
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "stealth"
}
```

v2 `~/.config/opencode/cli.json`:

```json
{
  "$schema": "https://opencode.ai/v2/cli.json",
  "theme": { "name": "stealth", "mode": "system" }
}
```

## Verify

```bash
# confirm the theme file exists
ls ~/.config/opencode/themes/

# confirm the active theme
cat ~/.config/opencode/tui.json    # v1
cat ~/.config/opencode/cli.json    # v2
```

Then restart OpenCode and open `Ctrl+P` → Theme.

## Uninstall

```bash
./uninstall.sh
# variants: ./uninstall.sh --variant amber
# v2:       ./uninstall.sh --v2
```

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

Uninstall removes the theme file and restores `opencode` in the config only if the active
theme matches the one being removed.

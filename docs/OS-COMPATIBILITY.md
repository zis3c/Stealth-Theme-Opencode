# OS Compatibility

## Support matrix

| OS | Level | Installer | Notes |
|---|---|---|---|
| Linux amd64/arm64 | Full | `install.sh` | Reference platform. |
| macOS | Full | `install.sh` | Uses default `bash` 3.2; no GNU-only tools required. |
| Windows PowerShell 5.1+ | Full | `install.ps1` | Native install/uninstall. |
| Windows cmd.exe | Full | `install.cmd` | Wrapper around PowerShell. |
| Windows Git Bash | Full | `install.sh` | Requires Python or `jq` for config merge. |
| WSL2 | Full | `install.sh` | Config path follows the Linux home inside WSL. |

## Requirements per platform

| Platform | Config merge | Fallback |
|---|---|---|
| Linux / macOS | `python3` or `python` | `jq`; if neither exists and no config file is present, creates a fresh `tui.json` |
| Windows PowerShell | Built-in JSON cmdlets | none needed |
| Git Bash / WSL | `python3` or `python` | `jq` |

## Limitations

- The theme only affects the OpenCode TUI. It does not restyle the OpenCode web UI,
  editor integrations or terminal scrollback.
- Transparent surfaces require a terminal that renders background transparency. If your
  terminal paints an opaque background, panels will match that background instead of
  showing content behind them.
- OpenCode v2 is still migrating native V2 theme files; V1 custom themes are supported via
  runtime migration. See [`THEMING.md`](THEMING.md).
- Badge images for the CI workflow do not render publicly while the repository is private.

## Tested by CI

`.github/workflows/ci.yml` runs:

- Theme validation on Ubuntu.
- Shell installer tests on Ubuntu, macOS and Windows (Git Bash).
- PowerShell installer tests on Windows.
- PowerShell and Bash syntax checks.

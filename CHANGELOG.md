# Changelog

## 1.0.0 - 2026-11-13

- Initial public release of the stealth theme for OpenCode.
- Transparent app, panel, input and dialog surfaces; gray-only palette with light and dark
  variants.
- Native installers for Linux, macOS and Windows (Bash, PowerShell and CMD wrappers).
- Optional `amber` and `green` variants via `--variant` / `-Variant`.
- OpenCode v2 `cli.json` support with automatic detection.
- Uninstallers restore the default OpenCode theme and preserve unrelated settings.
- Theme validation and installer tests covering Ubuntu, macOS and Windows (Git Bash) plus
  Windows PowerShell.
- Release workflow that attaches the theme files and a zip archive to `v*` tags.

### Fixes

- `backgroundMenu` is transparent so dialogs and "click to expand" popups match the terminal.
- Installer no longer uses GNU-only `install`; macOS `bash` 3.2 is supported.
- `.gitattributes` keeps `install.sh`/`uninstall.sh` on LF for Windows checkouts.

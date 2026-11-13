# Windows

Native Windows is supported through PowerShell. The Bash installer also works from Git
Bash and WSL.

## PowerShell (recommended)

```powershell
git clone https://github.com/zis3c/Stealth-Theme-Opencode.git
cd Stealth-Theme-Opencode
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Variants and v2:

```powershell
.\install.ps1 -Variant amber
.\install.ps1 -V2
```

If script execution is blocked, use `-ExecutionPolicy Bypass` as shown above or run the
`.cmd` wrapper, which already passes that flag.

## Double-click

- `install.cmd` - install the default gray theme.
- `uninstall.cmd` - restore the default OpenCode theme.

## Paths

| Item | Path |
|---|---|
| Config | `%USERPROFILE%\.config\opencode` |
| Theme | `%USERPROFILE%\.config\opencode\themes\<theme>.json` |
| v1 settings | `%USERPROFILE%\.config\opencode\tui.json` |
| v2 settings | `%USERPROFILE%\.config\opencode\cli.json` |

Override the config directory:

```powershell
.\install.ps1 -ConfigDir "D:\tools\opencode-config"
```

## Git Bash / WSL

```bash
./install.sh
```

Git Bash uses the Windows home directory. WSL uses the Linux home inside the distribution;
if OpenCode runs on Windows, install from PowerShell instead.

## Uninstall

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
# or double-click uninstall.cmd
```

## Troubleshooting

- **Theme does not appear**: restart OpenCode; themes are loaded at startup.
- **"running scripts is disabled"**: use `-ExecutionPolicy Bypass` or `install.cmd`.
- **Theme not applied**: confirm `tui.json` (v1) or `cli.json` (v2) points at the theme name.
- **No transparency**: check the terminal background and transparency settings; the theme
  cannot make an opaque terminal background transparent.

# Contributing

Contributions should improve the theme files, installers, tests or documentation. Keep
the theme presentation-only: do not add code that modifies OpenCode behavior.

Before submitting:

```bash
python tests/test_theme.py
bash -n install.sh uninstall.sh tests/test-install.sh
bash tests/test-install.sh
pwsh -NoProfile -File tests/test-install.ps1   # if PowerShell is available
git diff --check
```

Guidelines:

- Keep `background`, `backgroundPanel`, `backgroundElement` and `backgroundMenu`
  transparent in bundled themes.
- Test install and uninstall on at least one platform.
- Update `CHANGELOG.md` for user-visible changes.
- Do not commit credentials, machine-specific paths or generated archives.

CI runs the theme checks on Ubuntu and the installer tests on Ubuntu, macOS and Windows.
Pull requests that fail any job are not merged.

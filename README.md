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

> Newer opencode releases may use `cli.json` and a `{ "name", "mode" }` theme
> object. If your version differs, copy `themes/stealth.json` into the theme
> directory it documents and select `stealth`.

## Install

```bash
git clone <your-fork-url> opencode-stealth-theme
cd opencode-stealth-theme
./install.sh
```

The installer copies the theme and sets `"theme": "stealth"` in `tui.json`,
preserving any existing settings.

Then restart opencode.

### Manual install

```bash
mkdir -p ~/.config/opencode/themes
cp themes/stealth.json ~/.config/opencode/themes/
```

Edit or create `~/.config/opencode/tui.json`:

```json
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "stealth"
}
```

## Switching themes

- In the TUI: `Ctrl+P` → Theme → choose `stealth` or `opencode`.
- Or edit `~/.config/opencode/tui.json`:
  - `"theme": "stealth"` for the plain look
  - `"theme": "opencode"` for the default theme

## Tuning

Edit `~/.config/opencode/themes/stealth.json`. Useful knobs:

| Token | Purpose |
| --- | --- |
| `darkMuted` / `lightMuted` | placeholder and secondary text |
| `darkFaint` / `lightFaint` | comments, faint text |
| `darkElement` / `lightElement` | input/selection surface (`transparent` = terminal bg) |
| `backgroundMenu` | menus and dialogs (kept slightly opaque for readability) |
| `primary` / `accent` | interactive highlights and headings |

Set `backgroundElement` to `"transparent"` to make the input box match your
terminal background exactly.

## Uninstall

```bash
rm -f ~/.config/opencode/themes/stealth.json
```

Then set `"theme": "opencode"` in `~/.config/opencode/tui.json` (or pick another
theme in `Ctrl+P` → Theme).

## License

MIT — see [LICENSE](LICENSE).

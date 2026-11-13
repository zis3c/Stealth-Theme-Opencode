# Theming

## Format

The bundled themes use the OpenCode 1.x theme format:

```json
{
  "$schema": "https://opencode.ai/theme.json",
  "defs": {
    "darkBg": "transparent"
  },
  "theme": {
    "background": { "dark": "darkBg", "light": "transparent" },
    "text": { "dark": "#c6c6c6", "light": "#2a2a2a" }
  }
}
```

Each token has a `dark` and a `light` value. A value may be:

- a hex color (`#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`);
- `transparent`;
- the name of an entry in `defs` or in `theme`.

OpenCode v2 migrates V1 custom themes to its semantic token model at runtime, so the same
file works for v1 and v2. V2 CLI settings live in `cli.json`:

```json
{
  "$schema": "https://opencode.ai/v2/cli.json",
  "theme": { "name": "stealth", "mode": "system" }
}
```

See the [OpenCode themes documentation](https://opencode.ai/docs/themes) for the current V2
reference.

## Bundled themes

| File | Accent | Use |
|---|---|---|
| `themes/stealth.json` | none (pure gray) | Default stealth look |
| `themes/stealth-amber.json` | muted amber | Slightly warmer accent |
| `themes/stealth-green.json` | muted green | Slightly cooler accent |

All variants keep transparent `background`, `backgroundPanel`, `backgroundElement` and
`backgroundMenu` surfaces.

## Important tokens

| Token | Purpose |
|---|---|
| `background` | App background |
| `backgroundPanel` | Panels and sidebars |
| `backgroundElement` | Input box and selected-element surface |
| `backgroundMenu` | Menus, dialogs and "click to expand" popups |
| `text` | Primary text |
| `textMuted` | Placeholder and secondary text |
| `border`, `borderActive`, `borderSubtle` | Focus and separators |
| `primary`, `accent` | Interactive highlights and headings |
| `syntax*`, `markdown*`, `diff*` | Code, markdown and diff colors |

Set `backgroundElement` and `backgroundMenu` to `"transparent"` to make the input box and
dialogs inherit the terminal background.

## Customizing

1. Copy a bundled theme to a new name, for example `themes/my-stealth.json`.
2. Edit the `dark` / `light` values.
3. Install it manually or extend the installer mapping.
4. Restart OpenCode after changing a theme file.

The tests treat `background`, `backgroundPanel`, `backgroundElement` and `backgroundMenu` as
transparent surfaces; keep them transparent if you want the stealth effect.

## Caveats

- Theme tokens cannot hide UI elements or change layout. Use OpenCode settings
  (`Ctrl+P`) for sidebar, timestamps, tool details and animations.
- Truecolor support is recommended for accurate grays.

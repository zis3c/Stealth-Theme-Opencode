#!/usr/bin/env python3
"""Validate the stealth theme file structure and color references."""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
THEME = ROOT / "themes" / "stealth.json"

REQUIRED = [
    "primary", "secondary", "accent", "error", "warning", "success", "info",
    "text", "textMuted", "background", "backgroundPanel", "backgroundElement",
    "backgroundMenu", "border", "borderActive", "borderSubtle",
    "diffAdded", "diffRemoved", "diffContext", "diffHunkHeader",
    "diffHighlightAdded", "diffHighlightRemoved", "diffAddedBg", "diffRemovedBg",
    "diffContextBg", "diffLineNumber", "diffAddedLineNumberBg",
    "diffRemovedLineNumberBg", "markdownText", "markdownHeading", "markdownLink",
    "markdownLinkText", "markdownCode", "markdownBlockQuote", "markdownEmph",
    "markdownStrong", "markdownHorizontalRule", "markdownListItem",
    "markdownListEnumeration", "markdownImage", "markdownImageText",
    "markdownCodeBlock", "syntaxComment", "syntaxKeyword", "syntaxFunction",
    "syntaxVariable", "syntaxString", "syntaxNumber", "syntaxType",
    "syntaxOperator", "syntaxPunctuation",
]

HEX = re.compile(r"^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")

errors = []


def fail(msg):
    errors.append(msg)


def resolve(value, defs, theme, seen=None):
    seen = seen or []
    if not isinstance(value, str):
        return value
    if value in ("transparent", "none"):
        return value
    if value.startswith("#"):
        return value
    if value in seen:
        raise ValueError(f"circular reference: {' -> '.join(seen + [value])}")
    target = defs.get(value, theme.get(value))
    if target is None:
        raise ValueError(f"unknown color reference: {value}")
    if isinstance(target, dict):
        raise ValueError(f"cannot resolve mode-less reference: {value}")
    return resolve(target, defs, theme, seen + [value])


def main():
    if not THEME.exists():
        print(f"missing theme file: {THEME}", file=sys.stderr)
        return 1

    try:
        data = json.loads(THEME.read_text(encoding="utf-8"))
    except (ValueError, OSError) as exc:
        print(f"invalid JSON: {exc}", file=sys.stderr)
        return 1

    if not isinstance(data, dict) or "theme" not in data:
        print("theme file must be an object with a 'theme' key", file=sys.stderr)
        return 1

    defs = data.get("defs", {})
    theme = data["theme"]
    if not isinstance(defs, dict) or not isinstance(theme, dict):
        print("'defs' and 'theme' must be objects", file=sys.stderr)
        return 1

    for key in REQUIRED:
        if key not in theme:
            fail(f"missing theme token: {key}")
            continue
        entry = theme[key]
        if not isinstance(entry, dict):
            fail(f"{key} must be an object with dark/light values")
            continue
        for mode in ("dark", "light"):
            if mode not in entry:
                fail(f"{key} missing {mode} value")
                continue
            try:
                resolved = resolve(entry[mode], defs, theme)
            except ValueError as exc:
                fail(f"{key}.{mode}: {exc}")
                continue
            if not (resolved in ("transparent", "none") or HEX.match(str(resolved))):
                fail(f"{key}.{mode} is not a valid color: {resolved!r}")

    # Regression checks: the TUI surfaces must blend with the terminal.
    for key in ("background", "backgroundPanel", "backgroundElement", "backgroundMenu"):
        if key in theme:
            for mode in ("dark", "light"):
                try:
                    resolved = resolve(theme[key][mode], defs, theme)
                except ValueError:
                    continue
                if resolved != "transparent":
                    fail(f"{key}.{mode} should be transparent (got {resolved!r})")

    if errors:
        print("theme validation failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print(f"theme validation passed ({len(theme)} tokens)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

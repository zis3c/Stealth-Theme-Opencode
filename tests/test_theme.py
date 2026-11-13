#!/usr/bin/env python3
"""Validate all bundled theme files and their color references."""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
THEMES = ROOT / "themes"

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
TRANSPARENT_SURFACES = ("background", "backgroundPanel", "backgroundElement", "backgroundMenu")


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


def validate(path):
    errors = []

    def fail(msg):
        errors.append(f"{path.name}: {msg}")

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (ValueError, OSError) as exc:
        return [f"{path.name}: invalid JSON: {exc}"]

    if not isinstance(data, dict) or "theme" not in data:
        return [f"{path.name}: must be an object with a 'theme' key"]

    defs = data.get("defs", {})
    theme = data["theme"]
    if not isinstance(defs, dict) or not isinstance(theme, dict):
        return [f"{path.name}: 'defs' and 'theme' must be objects"]

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

    for key in TRANSPARENT_SURFACES:
        if key in theme:
            for mode in ("dark", "light"):
                try:
                    resolved = resolve(theme[key][mode], defs, theme)
                except (ValueError, KeyError, TypeError):
                    continue
                if resolved != "transparent":
                    fail(f"{key}.{mode} should be transparent (got {resolved!r})")

    return errors


def main():
    files = sorted(THEMES.glob("*.json"))
    if not files:
        print(f"no theme files found in {THEMES}", file=sys.stderr)
        return 1

    all_errors = []
    for path in files:
        errors = validate(path)
        if errors:
            all_errors.extend(errors)
        else:
            data = json.loads(path.read_text(encoding="utf-8"))
            print(f"ok: {path.name} ({len(data['theme'])} tokens)")

    if all_errors:
        print("theme validation failed:", file=sys.stderr)
        for error in all_errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print(f"theme validation passed ({len(files)} files)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

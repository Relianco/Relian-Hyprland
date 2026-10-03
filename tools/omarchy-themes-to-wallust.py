#!/usr/bin/env python3
"""Regenerate config/wallust/colorschemes/*.json from Omarchy's themes (github.com/basecamp/omarchy, branch quattro).
Usage: tools/omarchy-themes-to-wallust.py   (needs `gh` logged in, or network via gh api)
Omarchy colors.toml uses semantic names; wallust wants 16 terminal slots. color12 is the ACCENT on purpose:
this repo uses color12 for the active window border, waybar highlights and rofi selection."""
import json, subprocess, sys, tomllib, pathlib

OUT = pathlib.Path(__file__).resolve().parent.parent / "config/wallust/colorschemes"
REPO, REF = "basecamp/omarchy", "quattro"

def gh(path):
    return subprocess.run(["gh", "api", f"repos/{REPO}/contents/{path}?ref={REF}", "-H", "Accept: application/vnd.github.raw"],
                          check=True, capture_output=True, text=True).stdout

names = [e["name"] for e in json.loads(subprocess.run(["gh", "api", f"repos/{REPO}/contents/themes?ref={REF}"], check=True, capture_output=True, text=True).stdout) if e["type"] == "dir"]
OUT.mkdir(parents=True, exist_ok=True)
for n in names:
    try: c = tomllib.loads(gh(f"themes/{n}/colors.toml"))
    except subprocess.CalledProcessError: print("skip (no colors.toml):", n); continue
    if c.get("mode") == "light": print("skip (light theme):", n); continue   # dark-only carousel by choice
    g = lambda k, d=None: c.get(k, c.get(d) if d else None)
    slots = [g("dark_background", "background"), g("red"), g("green"), g("yellow"), g("blue"), g("magenta"), g("cyan"), g("foreground"),
             g("muted", "dark_foreground"), g("bright_red", "red"), g("bright_green", "green"), g("bright_yellow", "yellow"),
             g("accent", "bright_blue"), g("bright_magenta", "magenta"), g("bright_cyan", "cyan"), g("bright_foreground", "foreground")]
    if None in slots: sys.exit(f"{n}: missing colors {slots}")
    doc = {"wallpaper": "", "alpha": "100",
           "special": {"background": c["background"], "foreground": c["foreground"], "cursor": c["foreground"]},
           "colors": {f"color{i}": v for i, v in enumerate(slots)}}
    (OUT / f"omarchy-{n}.json").write_text(json.dumps(doc, indent=2) + "\n")
    print("ok", n)

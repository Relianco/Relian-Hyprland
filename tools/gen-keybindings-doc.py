#!/usr/bin/env python3
"""Generate docs/KEYBINDINGS.md from the Lua bind files, so the doc cannot drift from the config.
Usage: tools/gen-keybindings-doc.py [--check]   (--check exits 1 if the committed file is out of date)"""
import re, sys, pathlib

root = pathlib.Path(__file__).resolve().parent.parent
SOURCES = [("Default binds", "config/hypr/configs/Keybinds.lua"),
           ("Your binds", "config/hypr/UserConfigs/UserKeybinds.lua"),
           ("Laptop keys", "config/hypr/configs/Laptops.lua")]
DIGITS = {f"code:{10 + i}": str((i + 1) % 10) for i in range(10)}   # code:10 = key 1 ... code:19 = key 0

def pretty(combo):
    return " + ".join(DIGITS.get(p.strip(), p.strip()) for p in combo.split(" + "))

def parse(path):
    text = (root / path).read_text(encoding="utf-8")
    rows, section = [], ""
    lines = text.split("\n")
    for i, line in enumerate(lines):
        c = re.match(r"^--\s+([A-Z][^=]{2,40})$", line.strip())
        if c and not line.strip().startswith("--- ") and "http" not in line:
            section = c.group(1).strip().rstrip(":")
        m = re.match(r'^\s*hl\.bind\("([^"]+)"', line)
        if not m: continue
        desc = ""
        for j in range(i, min(i + 8, len(lines))):          # description is on the same bind (maybe a few lines down)
            d = re.search(r'description = "([^"]*)"', lines[j])
            if d: desc = d.group(1); break
            if j > i and lines[j].lstrip().startswith("hl.bind("): break
        rows.append((section, pretty(m.group(1)), desc or "(no description)"))
    return rows

out = ["# Keybindings", "",
       "Generated from the Lua config by `tools/gen-keybindings-doc.py` (a test fails if this file is out of date).",
       "`SUPER` is the Windows key. In your running session, **SUPER + H** shows this list, **SUPER + SHIFT + K** searches the live binds.", ""]
for title, path in SOURCES:
    rows = parse(path)
    if not rows: continue
    out += [f"## {title}", "", f"Source: `{path}`", ""]
    last = None
    for section, combo, desc in rows:
        if section != last:
            if last is not None: out.append("")
            if section: out += [f"### {section}", ""]
            out += ["| Keys | What it does |", "|---|---|"]
            last = section
        out.append(f"| `{combo}` | {desc} |")
    out.append("")
out += ["## Resize (generated in a loop)", "",
        "In `UserConfigs/UserKeybinds.lua`, on the `-` and `=` keys (Omarchy's layout):", "",
        "| Keys | What it does |", "|---|---|",
        "| `SUPER + -` / `SUPER + =` | narrower / wider by 100px |",
        "| `SUPER + SHIFT + -` / `=` | shorter / taller by 100px |",
        "| add `ALT` | small steps (25px) |", "| add `CTRL` | big steps (300px) |", ""]
doc = "\n".join(out)
target = root / "docs/KEYBINDINGS.md"
if "--check" in sys.argv:
    sys.exit(0 if target.exists() and target.read_text(encoding="utf-8") == doc else 1)
target.write_text(doc, encoding="utf-8"); print("wrote", target, "(%d lines)" % doc.count("\n"))

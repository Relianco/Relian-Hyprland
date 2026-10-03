#!/usr/bin/env python3
"""Turn the Relian emblem (config/hypr/branding/relian-emblem.svg) into ASCII art for the screensaver.

Usage: tools/make-ascii-logo.py [--style outline|shaded|scan|solid] [--rows 24] [--wordmark priest|graffiti|thin|dos_rebel|bloody|block] [--cell-aspect 3.5] [-o FILE] | --all
  outline bright contour, fading interior, light drop shadow: sleek wireframe     (default)
  shaded  classic 90s look: solid body, soft shaded edges, drop shadow
  scan    scanlines (retro CRT)
  solid   crisp half-block rendering, no shading
  --wordmark [block|thin]   add RELIAN lettering under the emblem (thin = slim double-line, block = chunky)
Needs rsvg-convert, Pillow and numpy. The output goes to stdout unless -o is given."""
import argparse, pathlib, subprocess, sys, tempfile
import numpy as np
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
SVG = ROOT / "config/hypr/branding/relian-emblem.svg"

WORDMARK = [
    "██████╗ ███████╗██╗     ██╗ █████╗ ███╗   ██╗",
    "██╔══██╗██╔════╝██║     ██║██╔══██╗████╗  ██║",
    "██████╔╝█████╗  ██║     ██║███████║██╔██╗ ██║",
    "██╔══██╗██╔══╝  ██║     ██║██╔══██║██║╚██╗██║",
    "██║  ██║███████╗███████╗██║██║  ██║██║ ╚████║",
    "╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝",
]

# classic scene lettering, pre-rendered with figlet fonts (dos_rebel, bloody, delta_corps_priest_1) so there is no runtime dependency
SCENE = {
    "dos_rebel": [
        ' ███████████   ██████████ █████       █████   █████████   ██████   █████',
        '░░███░░░░░███ ░░███░░░░░█░░███       ░░███   ███░░░░░███ ░░██████ ░░███',
        ' ░███    ░███  ░███  █ ░  ░███        ░███  ░███    ░███  ░███░███ ░███',
        ' ░██████████   ░██████    ░███        ░███  ░███████████  ░███░░███░███',
        ' ░███░░░░░███  ░███░░█    ░███        ░███  ░███░░░░░███  ░███ ░░██████',
        ' ░███    ░███  ░███ ░   █ ░███      █ ░███  ░███    ░███  ░███  ░░█████',
        ' █████   █████ ██████████ ███████████ █████ █████   █████ █████  ░░█████',
        '░░░░░   ░░░░░ ░░░░░░░░░░ ░░░░░░░░░░░ ░░░░░ ░░░░░   ░░░░░ ░░░░░    ░░░░░',
    ],
    "bloody": [
        ' ██▀███  ▓█████  ██▓     ██▓ ▄▄▄       ███▄    █',
        '▓██ ▒ ██▒▓█   ▀ ▓██▒    ▓██▒▒████▄     ██ ▀█   █',
        '▓██ ░▄█ ▒▒███   ▒██░    ▒██▒▒██  ▀█▄  ▓██  ▀█ ██▒',
        '▒██▀▀█▄  ▒▓█  ▄ ▒██░    ░██░░██▄▄▄▄██ ▓██▒  ▐▌██▒',
        '░██▓ ▒██▒░▒████▒░██████▒░██░ ▓█   ▓██▒▒██░   ▓██░',
        '░ ▒▓ ░▒▓░░░ ▒░ ░░ ▒░▓  ░░▓   ▒▒   ▓▒█░░ ▒░   ▒ ▒',
        '  ░▒ ░ ▒░ ░ ░  ░░ ░ ▒  ░ ▒ ░  ▒   ▒▒ ░░ ░░   ░ ▒░',
        '  ░░   ░    ░     ░ ░    ▒ ░  ░   ▒      ░   ░ ░',
        '   ░        ░  ░    ░  ░ ░        ░  ░         ░',
    ],
    "graffiti": [
        '_____________________.____    .___   _____    _______',
        '\\______   \\_   _____/|    |   |   | /  _  \\   \\      \\',
        ' |       _/|    __)_ |    |   |   |/  /_\\  \\  /   |   \\',
        ' |    |   \\|        \\|    |___|   /    |    \\/    |    \\',
        ' |____|_  /_______  /|_______ \\___\\____|__  /\\____|__  /',
        '        \\/        \\/         \\/           \\/         \\/',
    ],
    "priest": [
        '   ▄████████    ▄████████  ▄█        ▄█     ▄████████ ███▄▄▄▄',
        '  ███    ███   ███    ███ ███       ███    ███    ███ ███▀▀▀██▄',
        '  ███    ███   ███    █▀  ███       ███▌   ███    ███ ███   ███',
        ' ▄███▄▄▄▄██▀  ▄███▄▄▄     ███       ███▌   ███    ███ ███   ███',
        '▀▀███▀▀▀▀▀   ▀▀███▀▀▀     ███       ███▌ ▀███████████ ███   ███',
        '▀███████████   ███    █▄  ███       ███    ███    ███ ███   ███',
        '  ███    ███   ███    ███ ███▌    ▄ ███    ███    ███ ███   ███',
        '  ███    ███   ██████████ █████▄▄██ █▀     ███    █▀   ▀█   █▀',
        '  ███    ███              ▀',
    ],
}

# slim double-line lettering (3 rows), letter-spaced; the classic scene-logo look
THIN = {
    "R": ["╦═╗", "╠╦╝", "╩╚═"], "E": ["╔═╗", "║╣ ", "╚═╝"], "L": ["╦  ", "║  ", "╩═╝"],
    "I": ["╦", "║", "╩"], "A": ["╔═╗", "╠═╣", "╩ ╩"], "N": ["╔╗╔", "║║║", "╝╚╝"],
}

def wordmark_lines(name):
    return WORDMARK if name == "block" else thin_wordmark() if name == "thin" else SCENE[name]

def thin_wordmark(gap=3):
    return [(" " * gap).join(THIN[ch][r] for ch in "RELIAN") for r in range(3)]

def emblem_alpha():
    with tempfile.TemporaryDirectory() as d:
        png = pathlib.Path(d) / "e.png"
        subprocess.run(["rsvg-convert", "-w", "1600", str(SVG), "-o", str(png)], check=True)
        im = Image.open(png).convert("RGBA")
    return im.crop(im.split()[3].getbbox()).split()[3]

def coverage(alpha, cols, rows):
    """area-averaged coverage 0..1 on a cols x rows grid"""
    return np.asarray(alpha.resize((cols, rows), Image.BOX), dtype=float) / 255.0

CELL_ASPECT = 3.5   # real cells are ~2.6x taller than wide; 3.5 deliberately stretches the emblem wider, which reads sleeker

def shaded(alpha, rows):
    cols = round(rows * CELL_ASPECT * alpha.width / alpha.height)
    c = coverage(alpha, cols, rows)
    pad_x, pad_y = 2, 1
    grid_c = np.zeros((rows + pad_y, cols + pad_x)); grid_c[:rows, :cols] = c
    shadow = np.zeros_like(grid_c); shadow[pad_y:, pad_x:] = c       # the same shape pushed down-right
    out = []
    for y in range(grid_c.shape[0]):
        line = ""
        for x in range(grid_c.shape[1]):
            v, s = grid_c[y, x], shadow[y, x]
            if v > 0.70: ch = "█"
            elif v > 0.45: ch = "▓"
            elif v > 0.25: ch = "▒"
            elif v > 0.08: ch = "░"
            elif s > 0.35: ch = "░"                                  # light shadow, only where the emblem is not
            else: ch = " "
            line += ch
        out.append(line.rstrip())
    return out

def edge_mask(c, thr=0.5):
    """cells that are inside the emblem but touch the outside (4-neighbourhood): its outline"""
    m = c > thr
    pad = np.pad(m, 1, constant_values=False)
    inner = pad[1:-1, 1:-1]
    touches = ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    return inner & touches

def outline(alpha, rows):
    """bright outline, fine fading interior (sleek), light drop shadow"""
    cols = round(rows * CELL_ASPECT * alpha.width / alpha.height)
    c = coverage(alpha, cols, rows)
    m = c > 0.5; e = edge_mask(c)
    out = []
    for y in range(rows + 1):
        line = ""
        for x in range(cols + 2):
            inside = y < rows and x < cols and m[y, x]
            sh = y >= 1 and x >= 2 and y - 1 < rows and x - 2 < cols and m[y - 1, x - 2]
            if inside and e[y, x]: ch = "█"
            elif inside:
                # fade the interior from the top-left (brighter) to the bottom-right (dimmer)
                t_ = (x / cols + y / rows) / 2
                ch = "▒" if t_ < 0.45 else "░"
            elif sh: ch = "░"
            else: ch = " "
            line += ch
        out.append(line.rstrip())
    return out

def scan(alpha, rows):
    """solid body drawn with scanlines (every other pixel row), soft left-to-right fade: retro CRT feel"""
    cols = round(rows * CELL_ASPECT * alpha.width / alpha.height)
    c = coverage(alpha, cols, rows * 2) > 0.5
    out = []
    for y in range(rows):
        line = ""
        for x in range(cols):
            top, bot = c[2 * y, x], c[2 * y + 1, x]
            line += "▀" if (top and bot) else "▄" if bot else "▀" if top else " "
        out.append(line.rstrip())
    return out

def solid(alpha, rows):
    cols = round(rows * CELL_ASPECT * alpha.width / alpha.height)
    c = coverage(alpha, cols, rows * 2) > 0.5                          # two pixel rows per text row
    out = []
    for y in range(rows):
        line = ""
        for x in range(cols):
            top, bot = c[2 * y, x], c[2 * y + 1, x]
            line += "█" if top and bot else "▀" if top else "▄" if bot else " "
        out.append(line.rstrip())
    return out

def center(lines, width):
    return [(" " * max(0, (width - len(l)) // 2)) + l for l in lines]

def render(style, rows, wordmark):
    art = {"shaded": shaded, "solid": solid, "outline": outline, "scan": scan}[style](emblem_alpha(), rows)
    width = max(len(l) for l in art)
    word = wordmark_lines(wordmark)
    width = max(width, max(len(l) for l in word))
    return "\n".join(center(art, width) + [""] + center(word, width)) + "\n"

def write_all():
    """the screensaver picks one of these at random each time it (re)starts; drop your own .txt in to add to the mix"""
    sets = {"large": (28, ("priest", "graffiti", "thin", "dos_rebel", "bloody")),     # emblem rows, lettering choices
            "small": (12, ("priest", "graffiti", "thin"))}                              # small screens: only lettering that fits
    for size, (rows, words) in sets.items():
        d = ROOT / "config/hypr/branding" / size; d.mkdir(parents=True, exist_ok=True)
        for old in d.glob("*.txt"): old.unlink()
        for style in ("outline", "shaded", "scan", "solid"):
            for word in words:
                (d / f"{style}-{word}.txt").write_text(render(style, rows, word))
    print("wrote", len(list((ROOT / "config/hypr/branding").glob("*/*.txt"))), "variants")

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--style", choices=["shaded", "solid", "outline", "scan"], default="outline")
    ap.add_argument("--rows", type=int, default=24)
    ap.add_argument("--wordmark", choices=["block", "thin", "dos_rebel", "bloody", "priest", "graffiti"], nargs="?", const="block", help="add lettering under the emblem")
    ap.add_argument("--cell-aspect", type=float, default=3.5, help="cell height/width used for the layout; 2.6 is true-to-shape, higher = wider emblem (default 3.5)")
    ap.add_argument("--all", action="store_true", help="write every style x lettering variant to config/hypr/branding/{large,small}/")
    ap.add_argument("-o", "--out")
    a = ap.parse_args()
    global CELL_ASPECT
    CELL_ASPECT = a.cell_aspect
    if a.all:
        return write_all()
    art = {"shaded": shaded, "solid": solid, "outline": outline, "scan": scan}[a.style](emblem_alpha(), a.rows)
    width = max(len(l) for l in art)
    if a.wordmark:
        word = wordmark_lines(a.wordmark)
        width = max(width, max(len(l) for l in word))
        art = center(art, width) + [""] + center(word, width)
    text = "\n".join(art) + "\n"
    (pathlib.Path(a.out).write_text(text) if a.out else sys.stdout.write(text))

if __name__ == "__main__":
    main()

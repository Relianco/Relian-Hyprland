#!/usr/bin/env python3
"""Build the "relian" SDDM login theme (minimal: pixel logo, padlock, password box) in one of the bundled color schemes.

Usage: tools/build-sddm-theme.py OUTDIR [--theme "Tokyo Night"]
  --theme defaults to your current carousel theme (~/.cache/hypr-dots-theme) or Catppuccin.
Layout and idea follow Omarchy's login theme (MIT); the artwork here is drawn from scratch.
Install it with tools/install-login.sh (needs sudo); preview it first with tools/preview-login.sh (no sudo)."""
import json, os, pathlib, re, shutil, sys
from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCHEMES = ROOT / "config/wallust/colorschemes"

# 5x7 pixel font for the logo
GLYPHS = {
    "R": ["1111.", "1...1", "1...1", "1111.", "1.1..", "1..1.", "1...1"],
    "E": ["11111", "1....", "1....", "1111.", "1....", "1....", "11111"],
    "L": ["1....", "1....", "1....", "1....", "1....", "1....", "11111"],
    "I": ["11111", "..1..", "..1..", "..1..", "..1..", "..1..", "11111"],
    "A": [".111.", "1...1", "1...1", "11111", "1...1", "1...1", "1...1"],
    "N": ["1...1", "11..1", "1.1.1", "1..11", "1...1", "1...1", "1...1"],
}

def slug(name): return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")

def load_colors(theme):
    f = SCHEMES / f"omarchy-{slug(theme)}.json"
    if not f.exists(): sys.exit(f"unknown theme {theme!r} (no {f.name})")
    d = json.loads(f.read_text())
    return {"bg": d["special"]["background"], "fg": d["special"]["foreground"],
            "accent": d["colors"]["color12"], "red": d["colors"]["color1"]}

def current_theme():
    p = pathlib.Path(os.environ.get("XDG_CACHE_HOME", pathlib.Path.home() / ".cache")) / "hypr-dots-theme"
    name = p.read_text().strip() if p.exists() else ""
    return name if name and (SCHEMES / f"omarchy-{slug(name)}.json").exists() else "Catppuccin"

def rgb(h, a=255): h = h.lstrip("#"); return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (a,)
def mix(a, b, t): return tuple(round(a[i] * (1 - t) + b[i] * t) for i in range(3)) + (255,)

def logo(path, color):
    s, gap = 22, 1
    w = 6 * 5 * s + 5 * gap * s
    im = Image.new("RGBA", (800, 188), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    x0, y0 = (800 - w) // 2, (188 - 7 * s) // 2
    for i, ch in enumerate("RELIAN"):
        for r, row in enumerate(GLYPHS[ch]):
            for c, v in enumerate(row):
                if v == "1":
                    x, y = x0 + (i * (5 + gap) + c) * s, y0 + r * s
                    d.rectangle([x, y, x + s - 1, y + s - 1], fill=color)
    im.save(path)

def lock(path, color):
    k = 4; W, H = 84 * k, 96 * k
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.rounded_rectangle([0, 40 * k, W - 1, H - 1], radius=10 * k, fill=color)                       # body
    d.arc([14 * k, 2 * k, 70 * k, 70 * k], 180, 360, fill=color, width=12 * k)                     # shackle top
    d.rectangle([14 * k, 36 * k, 26 * k, 48 * k], fill=color); d.rectangle([58 * k, 36 * k, 70 * k, 48 * k], fill=color)
    d.rectangle([14 * k, 34 * k, 26 * k, 42 * k], fill=color); d.rectangle([58 * k, 34 * k, 70 * k, 42 * k], fill=color)
    d.ellipse([34 * k, 56 * k, 50 * k, 72 * k], fill=(0, 0, 0, 255))                                  # keyhole
    d.rounded_rectangle([38 * k, 64 * k, 46 * k, 82 * k], radius=4 * k, fill=(0, 0, 0, 255))
    # keyhole as a cut-out so it works on any background
    alpha = im.split()[3]; hole = Image.new("L", im.size, 0); hd = ImageDraw.Draw(hole)
    hd.ellipse([34 * k, 56 * k, 50 * k, 72 * k], fill=255); hd.rounded_rectangle([38 * k, 64 * k, 46 * k, 82 * k], radius=4 * k, fill=255)
    out = Image.new("RGBA", im.size, color); out.putalpha(Image.composite(Image.new("L", im.size, 0), alpha, hole))
    out.resize((84, 96), Image.LANCZOS).save(path)

def entry(path, border, fill):
    im = Image.new("RGBA", (286, 48), border); d = ImageDraw.Draw(im)
    d.rectangle([2, 2, 283, 45], fill=fill); im.save(path)

def bullet(path, color):
    k = 4; im = Image.new("RGBA", (14 * k, 14 * k), (0, 0, 0, 0)); ImageDraw.Draw(im).ellipse([0, 0, 14 * k - 1, 14 * k - 1], fill=color)
    im.resize((14, 14), Image.LANCZOS).save(path)

QML = (ROOT / "config/sddm/relian/Main.qml").read_text()

def build(out, theme):
    c = load_colors(theme); out = pathlib.Path(out); out.mkdir(parents=True, exist_ok=True)
    bg, fg, accent, red = rgb(c["bg"]), rgb(c["fg"]), rgb(c["accent"]), rgb(c["red"])
    lock(out / "lock.png", mix(accent, fg, 0.25)); lock(out / "lock-failed.png", red)
    entry(out / "entry.png", mix(accent, fg, 0.25), mix(bg, (0, 0, 0, 255), 0.45))
    entry(out / "entry-failed.png", red, mix(bg, red, 0.15))
    bullet(out / "bullet.png", mix(accent, fg, 0.25))
    # animated backdrop: the screensaver art (every large variant) as a JS array the QML cycles through
    arts = sorted((ROOT / "config/hypr/branding/large").glob("*.txt"))
    (out / "art.js").write_text("var ART = " + json.dumps([f.read_text().rstrip("\n") for f in arts], ensure_ascii=False) + ";\n")
    (out / "Main.qml").write_text(QML.replace("@BG@", c["bg"]).replace("@ACCENT@", c["accent"]))
    shutil.copy(ROOT / "config/sddm/relian/theme.conf", out / "theme.conf")
    shutil.copy(ROOT / "config/sddm/relian/metadata.desktop", out / "metadata.desktop")
    print(f"built SDDM theme 'relian' ({theme}) in {out}")

if __name__ == "__main__":
    args = sys.argv[1:]
    if not args or args[0].startswith("-"): sys.exit(__doc__)
    theme = args[args.index("--theme") + 1] if "--theme" in args else current_theme()
    build(args[0], theme)

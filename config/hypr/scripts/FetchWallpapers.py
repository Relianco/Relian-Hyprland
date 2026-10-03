#!/usr/bin/env python3
"""Download ultrawide (32:9, at least 5120x1440 so nothing is upscaled) wallpapers from wallhaven.cc into ~/Pictures/wallpapers (SFW, general category, most favorited).

  FetchWallpapers.py [--per-query 2] [--queries space,nebula,aurora,...] [--out DIR] [--list]
Images stay on your machine (not in the repo): wallhaven wallpapers carry their authors' own licences.
Anything wider than 5120 px is scaled down to 5120x1440 so files stay a sensible size. No account or API key needed."""
import argparse, json, pathlib, subprocess, sys, time, urllib.parse, urllib.request
from io import BytesIO
from PIL import Image

QUERIES = "space,nebula,aurora,mountain,city,abstract,forest,ocean,minimal,night".split(",")
API = "https://wallhaven.cc/api/v1/search?"
UA = {"User-Agent": "Relian-Hyprland wallpaper fetcher"}


def get(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60).read()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--per-query", type=int, default=2)
    ap.add_argument("--queries", default=",".join(QUERIES))
    ap.add_argument("--out", default=str(pathlib.Path.home() / "Pictures/wallpapers"))
    ap.add_argument("--list", action="store_true", help="show what would be downloaded")
    a = ap.parse_args()
    out = pathlib.Path(a.out); out.mkdir(parents=True, exist_ok=True)
    seen = set()
    for q in a.queries.split(","):
        qs = urllib.parse.urlencode({"q": q, "ratios": "32x9", "atleast": "5120x1440", "sorting": "favorites",
                                     "purity": "100", "categories": "100"})
        data = json.loads(get(API + qs))["data"]
        n = 0
        for w in data:
            if n >= a.per_query: break
            if w["id"] in seen: continue
            seen.add(w["id"]); n += 1
            dest = out / f"wallhaven-{w['id']}.jpg"
            if dest.exists(): print("have", dest.name); continue
            print(f"{'would get' if a.list else 'get'} {w['id']} {w['resolution']} ({q}, {w['favorites']} favorites)", flush=True)
            if a.list: continue
            im = Image.open(BytesIO(get(w["path"]))).convert("RGB")
            if im.width > 5120: im = im.resize((5120, round(im.height * 5120 / im.width)), Image.LANCZOS)
            im.save(dest, quality=93, subsampling=0)
        time.sleep(1.2)   # be polite to the API (45 requests/minute allowed)
    s = pathlib.Path.home() / ".config/hypr/UserScripts/WallpaperSelect.sh"
    if s.exists() and not a.list: subprocess.run([str(s), "--warm"])   # build the picker thumbnails now


if __name__ == "__main__":
    main()

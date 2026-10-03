#!/usr/bin/env python3
"""Download slow, ambient 4K looping videos for use as animated wallpapers (mpvpaper) into ~/Pictures/wallpapers/animated.

  FetchAnimated.py [--max-gb 20] [--out DIR] [--sources mixkit,wikimedia] [--motion 6.0] [--dry-run]

Sources (no account or API key):
  mixkit     mixkit.co free stock video (Mixkit licence: free personal use, no attribution; not redistributed by this repo)
  wikimedia  Wikimedia Commons video (public domain / CC; credits are written to CREDITS.txt next to the files)
Only 3840x2160 or larger, at least 8 s long, hardware-decodable codecs (H.264/HEVC/VP9/AV1). Fast clips are dropped: each download is
measured (average change between frames, 4 samples/s) and kept only if it is under --motion, because quick movement is tiring on a
screen this wide. Stops at --max-gb. Safe to re-run: files already there are skipped. Needs ffmpeg/ffprobe."""
import argparse, json, shutil, pathlib, re, subprocess, sys, tempfile, time, urllib.parse, urllib.request

UA = {"User-Agent": "Mozilla/5.0 (Relian-Hyprland wallpaper fetcher)"}
MIXKIT_CATS = ["space", "nature", "sky", "abstract", "background", "3d-animation", "clouds", "aurora", "ocean", "stars", "galaxy", "night", "rain", "city"]
WIKI_QUERIES = ["nebula", "galaxy", "aurora", "earth from orbit", "ocean waves", "clouds", "northern lights", "milky way", "sun", "moon"]
WIKI_SKIP = re.compile(r"\b(pan|panning|timelapse|time-lapse|fly|flight|zoom|tour)\b", re.I)
OK_CODECS = {"h264", "hevc", "vp9", "av1"}
OK_LICENCES = re.compile(r"^(public domain|pd|cc0|cc[ -]by(?!-nc)|cc[ -]by-sa)", re.I)


def get(url, binary=True, method="GET", timeout=60):
    req = urllib.request.Request(url, headers=UA, method=method)
    r = urllib.request.urlopen(req, timeout=timeout)
    return r if method == "HEAD" else (r.read() if binary else r.read().decode("utf-8", "replace"))


def head(url):
    try:
        r = get(url, method="HEAD", timeout=20)
        return r.headers.get("Content-Type", ""), int(r.headers.get("Content-Length", 0))
    except Exception:
        return "", 0


def probe(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=codec_name,width,height",
                          "-show_entries", "format=duration", "-of", "json", str(path)], capture_output=True, text=True).stdout
    d = json.loads(out or "{}")
    s = (d.get("streams") or [{}])[0]
    return s.get("codec_name", ""), s.get("width", 0), s.get("height", 0), float(d.get("format", {}).get("duration", 0) or 0)


def motion(path):
    """mean absolute difference between consecutive frames (4 fps, 192x108 grey, 0-255 scale): low = calm"""
    vf = "fps=4,scale=192:108,format=gray,tblend=all_mode=difference,signalstats,metadata=print:key=lavfi.signalstats.YAVG:file=-"
    out = subprocess.run(["ffmpeg", "-v", "error", "-t", "40", "-i", str(path), "-vf", vf, "-f", "null", "-"], capture_output=True, text=True).stdout
    v = [float(m) for m in re.findall(r"YAVG=([0-9.]+)", out)][1:]
    return sum(v) / len(v) if v else 999.0


def mixkit_candidates():
    seen = set()
    for cat in MIXKIT_CATS:
        for page in range(1, 9):
            try:
                html = get(f"https://mixkit.co/free-stock-video/{cat}/?page={page}", binary=False)
            except Exception:
                break
            slugs = dict((i, s) for s, i in re.findall(r'/free-stock-video/([a-z0-9-]+?)-(\d+)/"', html))
            ids = re.findall(r"assets\.mixkit\.co/videos/(\d+)/\1-360\.mp4", html)
            if not ids: break
            for i in ids:
                if i in seen: continue
                seen.add(i)
                yield {"name": f"mixkit-{slugs.get(i, 'clip')}-{i}.mp4", "url": f"https://assets.mixkit.co/videos/{i}/{i}-2160.mp4",
                       "credit": f"Mixkit clip {i} ({cat}) https://mixkit.co/free-stock-video/ - Mixkit Stock Video Free License"}
            time.sleep(0.5)


def wiki_candidates():
    seen = set()
    for q in WIKI_QUERIES:
        qs = urllib.parse.urlencode({"action": "query", "format": "json", "generator": "search", "gsrnamespace": 6, "gsrlimit": 50,
                                     "gsrsearch": f"{q} filetype:video", "prop": "imageinfo", "iiprop": "url|size|mime|extmetadata"})
        try:
            pages = json.loads(get("https://commons.wikimedia.org/w/api.php?" + qs, binary=False)).get("query", {}).get("pages", {})
        except Exception:
            continue
        for p in pages.values():
            ii = (p.get("imageinfo") or [{}])[0]
            title = p.get("title", "")
            lic = ii.get("extmetadata", {}).get("LicenseShortName", {}).get("value", "")
            if ii.get("width", 0) < 3840 or "webm" not in ii.get("mime", "") or title in seen: continue
            if WIKI_SKIP.search(title) or not OK_LICENCES.match(lic): continue
            seen.add(title)
            name = "wikimedia-" + re.sub(r"[^A-Za-z0-9]+", "-", title.removeprefix("File:").rsplit(".", 1)[0]).strip("-")[:60] + ".webm"
            yield {"name": name, "url": ii["url"], "credit": f"{title} ({lic}) https://commons.wikimedia.org/wiki/{urllib.parse.quote(title.replace(' ', '_'))}"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--max-gb", type=float, default=20)
    ap.add_argument("--out", default=str(pathlib.Path.home() / "Pictures/wallpapers/animated"))
    ap.add_argument("--sources", default="mixkit,wikimedia")
    ap.add_argument("--motion", type=float, default=6.0, help="reject clips whose average frame-to-frame change is above this")
    ap.add_argument("--dry-run", action="store_true", help="list what would be fetched without downloading")
    a = ap.parse_args()
    out = pathlib.Path(a.out); out.mkdir(parents=True, exist_ok=True)
    credits = out / "CREDITS.txt"
    total = sum(f.stat().st_size for f in out.glob("*") if f.suffix in (".mp4", ".webm"))
    cap = a.max_gb * 1e9
    gens = {"mixkit": mixkit_candidates, "wikimedia": wiki_candidates}
    kept = rejected = 0
    for src in a.sources.split(","):
        for c in gens[src]():
            if total >= cap: print(f"reached {a.max_gb} GB"); return
            dest = out / c["name"]
            if dest.exists(): continue
            ctype, size = head(c["url"])
            if "video" not in ctype or size == 0:
                continue                                  # no 4K version of this clip
            if a.dry_run: print(f"would get {c['name']} {size / 1e6:.0f} MB"); continue
            with tempfile.TemporaryDirectory() as tmp:
                f = pathlib.Path(tmp) / c["name"]
                try: f.write_bytes(get(c["url"], timeout=300))
                except Exception as e: print("failed", c["name"], e); continue
                codec, w, h, dur = probe(f)
                if codec not in OK_CODECS or w < 3840 or dur < 8: print(f"skip {c['name']}: {codec} {w}x{h} {dur:.0f}s"); rejected += 1; continue
                m = motion(f)
                if m > a.motion: print(f"skip {c['name']}: too much motion ({m:.1f})"); rejected += 1; continue
                shutil.move(str(f), dest)
            total += dest.stat().st_size; kept += 1
            with credits.open("a") as cf: cf.write(c["credit"] + "\n")
            print(f"kept {c['name']} {dest.stat().st_size / 1e6:.0f} MB, motion {m:.1f} ({total / 1e9:.1f} / {a.max_gb:g} GB)", flush=True)
    print(f"done: kept {kept}, rejected {rejected}, folder {total / 1e9:.1f} GB")


if __name__ == "__main__":
    main()

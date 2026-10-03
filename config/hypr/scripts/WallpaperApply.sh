#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Set the wallpaper: a still image (awww) or an animated video (mpvpaper, hardware decoded, pauses while covered).
#   WallpaperApply.sh FILE        set it, remember it, and re-derive colours if the theme is "Wallpaper colours"
#   WallpaperApply.sh --restore   at login: bring back the remembered one (no colour change)
# Env: MPVPAPER (path to the binary), WALLPAPER_STATE_DIR (tests)
state_dir=${WALLPAPER_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/relian}
state="$state_dir/wallpaper"
current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"   # a still of whatever is showing: hyprlock + "Wallpaper colours" read it
mpvp=${MPVPAPER:-mpvpaper}
is_video() { case "${1,,}" in *.mp4|*.mkv|*.mov|*.webm) return 0 ;; *) return 1 ;; esac; }

start_image_daemon() { pgrep -x awww-daemon >/dev/null || { awww-daemon --format xrgb >/dev/null 2>&1 & sleep 0.6; }; }

show() { # show FILE  (no colours, no state)
  local f=$1
  mkdir -p "$(dirname "$current")"
  if is_video "$f"; then
    command -v "$mpvp" >/dev/null 2>&1 || { notify-send "Animated wallpaper" "mpvpaper is not installed (paru -S mpvpaper)"; return 1; }
    pkill -x mpvpaper 2>/dev/null
    ffmpeg -v error -y -ss 2 -i "$f" -frames:v 1 "$current.png" && mv "$current.png" "$current"
    # -p: pause while the wallpaper is covered by windows (no CPU/GPU spent on what you cannot see)
    "$mpvp" -f -p -o "no-audio loop hwdec=auto-safe load-scripts=no panscan=1.0 video-unscaled=no" '*' "$f"
    pkill -x awww-daemon 2>/dev/null
  else
    pkill -x mpvpaper 2>/dev/null
    cp -f "$f" "$current" 2>/dev/null
    start_image_daemon
    awww img "$f" --transition-type any --transition-duration 1.5 --transition-fps 60 >/dev/null 2>&1
  fi
}

case "${1:-}" in
  --restore)
    f=$(cat "$state" 2>/dev/null)
    if [ -f "$f" ]; then show "$f"; else start_image_daemon; fi   # awww restores its own last image
    exit 0 ;;
  "") echo "usage: $0 FILE | --restore" >&2; exit 2 ;;
esac
f=$(realpath "$1") || exit 1
[ -f "$f" ] || { echo "no such file: $f" >&2; exit 1; }
show "$f" || exit 1
mkdir -p "$state_dir"; printf '%s' "$f" > "$state"
if [ "$(cat "${XDG_CACHE_HOME:-$HOME/.cache}/hypr-dots-theme" 2>/dev/null)" = "Wallpaper colours" ]; then
  "$HOME/.config/hypr/scripts/ThemeSelect.sh" --set "Wallpaper colours" >/dev/null 2>&1
fi

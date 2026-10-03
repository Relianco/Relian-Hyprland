#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Wallpaper picker (SUPER W): stills and animated videos from ~/Pictures/wallpapers, opens on the one in use.
# Thumbnails are cached in ~/.cache/relian/wallthumbs and built in parallel the first time, so later opens are quick.

terminal=kitty
wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
state="${XDG_STATE_HOME:-$HOME/.local/state}/relian/wallpaper"
iDIR="$HOME/.config/swaync/images"
rofi_theme="$HOME/.config/rofi/config-wallpaper.rasi"
rofi_override="element-icon{size:330px;}"

# files, sorted; one stat call gives every mtime (forking per file is what made this slow)
mapfile -d '' found < <(find -L "$wallDIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
  -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) -print0)
[[ ${#found[@]} -gt 0 ]] || { notify-send -i "$iDIR/error.png" "No wallpapers" "Put some in $wallDIR (or run FetchWallpapers.py)"; exit 1; }
mapfile -t PICS < <(printf '%s\n' "${found[@]}" | LC_ALL=C sort)
mapfile -t mtimes < <(stat -c '%Y' -- "${PICS[@]}")

thumb_dir="$HOME/.cache/relian/wallthumbs"
thumbs=()
for i in "${!PICS[@]}"; do
  k=${PICS[i]//[^A-Za-z0-9]/_}; thumbs[i]="$thumb_dir/${k: -140}_${mtimes[i]}.jpg"
done

make_thumb() { # make_thumb FILE THUMB
  local ss=()
  [[ "${1,,}" =~ \.(mp4|mkv|mov|webm)$ ]] && ss=(-ss 2)
  ffmpeg -v error -y "${ss[@]}" -i "$1" -frames:v 1 -vf "scale=500:-2" -q:v 5 "$2" 2>/dev/null \
    || ffmpeg -v error -y -i "$1" -frames:v 1 -vf "scale=500:-2" -q:v 5 "$2" 2>/dev/null
}
export -f make_thumb

build_thumbs() {
  mkdir -p "$thumb_dir"
  local i
  for i in "${!PICS[@]}"; do [[ -s "${thumbs[i]}" ]] || printf '%s\0%s\0' "${PICS[i]}" "${thumbs[i]}"; done \
    | xargs -0 -r -n 2 -P 12 bash -c 'make_thumb "$0" "$1"'
}

# row of the wallpaper in use (row 0 is ". random"), so the list opens on it
selected_row=0
cur=$(cat "$state" 2>/dev/null)
if [[ -n "$cur" ]]; then
  for i in "${!PICS[@]}"; do [[ "${PICS[i]}" == "$cur" ]] && { selected_row=$((i + 1)); break; }; done
fi

menu() {
  printf ". random\x00icon\x1f%s\n" "${thumbs[RANDOM % ${#thumbs[@]}]}"
  local i
  for i in "${!PICS[@]}"; do printf "%s\x00icon\x1f%s\n" "${PICS[i]##*/}" "${thumbs[i]}"; done
}

# Offer SDDM Simple Wallpaper Option (only for non-video wallpapers)
set_sddm_wallpaper() {
  sleep 1

  # Resolve SDDM themes directory (standard and NixOS path)
  local sddm_themes_dir=""
  if [ -d "/usr/share/sddm/themes" ]; then
    sddm_themes_dir="/usr/share/sddm/themes"
  elif [ -d "/run/current-system/sw/share/sddm/themes" ]; then
    sddm_themes_dir="/run/current-system/sw/share/sddm/themes"
  fi

  [ -z "$sddm_themes_dir" ] && return 0

  local sddm_simple="$sddm_themes_dir/simple_sddm_2"

  # Only prompt if theme exists and its Backgrounds directory is writable
  if [ -d "$sddm_simple" ] && [ -w "$sddm_simple/Backgrounds" ]; then

    # Check if yad is running to avoid multiple notifications
    if pidof yad >/dev/null; then
      killall yad
    fi

    if yad --info --text="Set current wallpaper as SDDM background?\n\nNOTE: This only applies to SIMPLE SDDM v2 Theme" \
      --text-align=left \
      --title="SDDM Background" \
      --timeout=5 \
      --timeout-indicator=right \
      --button="yes:0" \
      --button="no:1"; then

      # Check if terminal exists
      if ! command -v "$terminal" &>/dev/null; then
        notify-send -i "$iDIR/error.png" "Missing $terminal" "Install $terminal to enable setting of wallpaper background"
        exit 1
      fi

      exec "$SCRIPTSDIR/sddm_wallpaper.sh" --normal

    fi
  fi
}

# Apply a wallpaper (image or video): WallpaperApply.sh kills the other kind of daemon, starts the right one, remembers
# the choice for the next login and re-derives colours when the theme is "Wallpaper colours".
apply_wallpaper() { "$SCRIPTSDIR/WallpaperApply.sh" "$1"; set_sddm_wallpaper; }

main() {
  build_thumbs
  choice=$(menu | rofi -i -show -dmenu -config "$rofi_theme" -theme-str "$rofi_override" -selected-row "$selected_row")
  choice=$(echo "$choice" | xargs -0)
  choice=${choice%$'\n'}
  [[ -n "$choice" ]] || exit 0

  if [[ "$choice" == ". random" ]]; then
    selected_file=${PICS[RANDOM % ${#PICS[@]}]}
  else
    selected_file=""
    for f in "${PICS[@]}"; do [[ "${f##*/}" == "$choice" ]] && { selected_file=$f; break; }; done
  fi
  [[ -n "$selected_file" ]] || { echo "File not found: $choice"; exit 1; }
  apply_wallpaper "$selected_file"
}

# --warm: just build the thumbnails (the downloaders call this, so SUPER+W opens fast the first time too)
if [[ "${1:-}" == "--warm" ]]; then build_thumbs; exit 0; fi

# only one rofi at a time
pidof rofi >/dev/null && pkill rofi

main

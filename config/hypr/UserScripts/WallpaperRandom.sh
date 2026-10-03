#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# Script for Random Wallpaper ( CTRL ALT W)

wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

mapfile -d '' PICS < <(find -L "$wallDIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' \) -print0)
[ "${#PICS[@]}" -gt 0 ] || exit 0
"$SCRIPTSDIR/WallpaperApply.sh" "${PICS[RANDOM % ${#PICS[@]}]}"

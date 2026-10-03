#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Icon-theme and cursor-theme carousel (same keys as the colour theme carousel).
#   LookSelect.sh icons|cursors            LEFT/RIGHT cycle + preview, ENTER keep, ESC revert
#   LookSelect.sh icons|cursors --list     print the installed ones
#   LookSelect.sh icons|cursors --set NAME apply by name
# Env: LOOK_DIRS (colon list of icon dirs, tests), LOOK_NO_APPLY=1 (only write settings, no gsettings/hyprctl)
kind=${1:-}; shift
case "$kind" in icons|cursors) ;; *) echo "usage: $0 icons|cursors [--list|--set NAME]" >&2; exit 2 ;; esac

dirs=${LOOK_DIRS:-$HOME/.local/share/icons:$HOME/.icons:/usr/share/icons}
state="${XDG_STATE_HOME:-$HOME/.local/state}/relian"
rofi_theme="$HOME/.config/rofi/config-omarchy-launcher.rasi"

list() {
  local d t
  IFS=: read -ra ds <<< "$dirs"
  for d in "${ds[@]}"; do
    for t in "$d"/*/; do
      t=${t%/}; [ -f "$t/index.theme" ] || continue
      if [ "$kind" = cursors ]; then [ -d "$t/cursors" ] || continue
      else grep -q '^Directories=' "$t/index.theme" || continue; fi
      basename "$t"
    done
  done | grep -v -x -E 'hicolor|locolor|default|HighContrast' | sort -fu
}

current() {
  if [ "$kind" = cursors ]; then cat "$state/cursor-theme" 2>/dev/null || gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'"
  else gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'"; fi
}

setini() { # persist for GTK apps started later
  local f key=gtk-icon-theme-name; [ "$kind" = cursors ] && key=gtk-cursor-theme-name
  for f in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
    [ -f "$f" ] || continue
    if grep -q "^$key=" "$f"; then sed -i "s/^$key=.*/$key=$1/" "$f"; else sed -i "/^\[Settings\]/a $key=$1" "$f"; fi
  done
}

apply() {
  local n=$1 size
  setini "$n"
  if [ "$kind" = cursors ]; then
    mkdir -p "$state"; printf '%s' "$n" > "$state/cursor-theme"   # read by ENVariables.lua on the next Hyprland start
    [ -n "${LOOK_NO_APPLY:-}" ] && return 0
    gsettings set org.gnome.desktop.interface cursor-theme "$n" 2>/dev/null
    size=$(gsettings get org.gnome.desktop.interface cursor-size 2>/dev/null); size=${size:-24}
    hyprctl setcursor "$n" "$size" >/dev/null 2>&1
  else
    [ -n "${LOOK_NO_APPLY:-}" ] || gsettings set org.gnome.desktop.interface icon-theme "$n" 2>/dev/null
  fi
}

mapfile -t items < <(list)
[ "${#items[@]}" -gt 0 ] || { notify-send "No $kind installed" "nothing found in $dirs" 2>/dev/null; echo "none found" >&2; exit 1; }
case "${1:-}" in
  --list) printf '%s\n' "${items[@]}"; exit 0 ;;
  --set)  apply "${2:?name}"; exit ;;
esac

pkill rofi 2>/dev/null
original=$(current); sel=0
for i in "${!items[@]}"; do [ "${items[i]}" = "$original" ] && sel=$i; done
shown=$original; label=Icons; [ "$kind" = cursors ] && label=Cursor
while true; do
  choice=$(printf '%s\n' "${items[@]}" | rofi -dmenu -i -format i -selected-row "$sel" -no-custom \
    -theme "$rofi_theme" -theme-str "window { width: 460px; } entry { placeholder: \"$label theme\"; }" \
    -mesg "←/→ cycle and preview   Enter keep   Esc revert" \
    -kb-move-char-back "Control+b" -kb-move-char-forward "Control+f" -kb-row-up "Control+p" -kb-row-down "Control+n" \
    -kb-custom-1 "Left,Up" -kb-custom-2 "Right,Down")
  case $? in
    10) sel=$(( (sel - 1 + ${#items[@]}) % ${#items[@]} )); shown=${items[sel]}; apply "$shown" ;;
    11) sel=$(( (sel + 1) % ${#items[@]} )); shown=${items[sel]}; apply "$shown" ;;
    0)  apply "${items[choice]}"; exit 0 ;;
    *)  [ "$shown" = "$original" ] || apply "$original"; exit 0 ;;
  esac
done

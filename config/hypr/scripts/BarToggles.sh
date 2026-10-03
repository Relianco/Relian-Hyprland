#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Waybar toggles.  BarToggles.sh perf|dnd [toggle]
#   perf: power profile performance <-> balanced (power-profiles-daemon)    dnd: notifications on/off (swaync)
# No argument beyond the name prints Waybar JSON; "toggle" flips it and pokes the module (signals 14 / 15).
what=${1:-} act=${2:-}
case "$what" in
  perf)
    if [ "$act" = toggle ]; then
      [ "$(powerprofilesctl get 2>/dev/null)" = performance ] && p=balanced || p=performance
      powerprofilesctl set "$p" 2>/dev/null || notify-send "Performance mode" "power-profiles-daemon refused: $p"
      pkill -SIGRTMIN+14 waybar; exit 0
    fi
    p=$(powerprofilesctl get 2>/dev/null) || { echo '{"text":"󰓅","class":"missing","tooltip":"power-profiles-daemon not running"}'; exit 0; }
    [ "$p" = performance ] && cls=on || cls=off
    printf '{"text":"󰓅","class":"%s","tooltip":"Power profile: %s\\nClick: toggle performance mode"}\n' "$cls" "$p" ;;
  dnd)
    if [ "$act" = toggle ]; then swaync-client -d -sw >/dev/null; pkill -SIGRTMIN+15 waybar; exit 0; fi
    if [ "$(swaync-client -D 2>/dev/null)" = true ]; then
      echo '{"text":"󰂛","class":"on","tooltip":"Notifications silenced\nClick: turn back on"}'
    else
      echo '{"text":"󰂚","class":"off","tooltip":"Notifications on\nClick: do not disturb"}'
    fi ;;
  *) echo "usage: $0 perf|dnd [toggle]" >&2; exit 2 ;;
esac

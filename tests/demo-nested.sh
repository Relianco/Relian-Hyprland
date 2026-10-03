#!/usr/bin/env bash
# Try the Lua dots inside a window (nested Hyprland) without logging out. Close the window to quit.
# Uses a throwaway HOME: other apps' configs (waybar, rofi, ...) are symlinked from your real ~/.config,
# ~/.config/hypr is a copy of this repo's config/hypr. Startup entries that would touch your REAL session
# (dbus/systemd env import, hypridle, swaync, polkit, tray applets, ags, hyprsunset) are removed from the copy.
# Caveat: the outer compositor still gets Super+key first, so keybinds mostly won't reach the nested one.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
t=${DEMO_HOME:-$(mktemp -d)}; mkdir -p "$t/.config"
for d in "$HOME"/.config/*; do case "$(basename "$d")" in hypr|waybar) ;; *) ln -sfn "$d" "$t/.config/$(basename "$d")";; esac; done
# waybar: a copy of the repo's config (so new layouts/styles show up). WAYBAR_LAYOUT / WAYBAR_STYLE pick them.
rm -rf "$t/.config/waybar"; cp -r "$root/config/waybar" "$t/.config/waybar"
ln -sfn "$t/.config/waybar/configs/${WAYBAR_LAYOUT:-[TOP] Omarchy}" "$t/.config/waybar/config"
ln -sfn "$t/.config/waybar/style/${WAYBAR_STYLE:-[Omarchy] Minimal.css}" "$t/.config/waybar/style.css"
ln -sfn "$HOME/Pictures" "$t/Pictures"
rm -rf "$t/.config/hypr"; cp -r "$root/config/hypr" "$t/.config/hypr"
cd "$t/.config/hypr"
sed -i -E '/dbus-update-activation|systemctl --user|hypridle|swaync|nm-applet|nm-tray|Polkit|blueman|"ags"|Hyprsunset/d' configs/Startup_Apps.lua
python3 - <<'PY'
import re
t=open("hyprland.lua").read()
open("hyprland.lua","w").write(re.sub(r'hl\.on\("hyprland\.start", function\(\)\n.*?initial-boot.*?\nend\)\n','',t,flags=re.S))
PY
echo "nested demo HOME: $t"
# start-hyprland is the supported launcher (watchdog); running Hyprland directly makes it show a "don't launch me directly" warning
if command -v start-hyprland >/dev/null; then
  HOME="$t" exec start-hyprland -- -c "$t/.config/hypr/hyprland.lua"
fi
HOME="$t" exec Hyprland -c "$t/.config/hypr/hyprland.lua"

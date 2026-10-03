#!/usr/bin/env bash
# Copy this repo's config into ~/.config (nothing is deleted), after a timestamped backup.
# Run it (1) after pulling changes, and (2) once after Hyprland has restarted on hyprland.lua, so the
# Lua-aware scripts replace the old-format ones. Usage: tools/install-live.sh
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
backup="$HOME/.config-backup-relian-$(date +%Y%m%d-%H%M%S)"
dirs=(hypr waybar rofi wallust kitty swaync)

# GTK3: ship only our own CSS file and import it from your gtk.css (your accent colours etc. stay yours)
mkdir -p "$HOME/.config/gtk-3.0"
cp "$root/config/gtk-3.0/relian-thunar.css" "$HOME/.config/gtk-3.0/relian-thunar.css"
grep -q relian-thunar.css "$HOME/.config/gtk-3.0/gtk.css" 2>/dev/null || printf '\n@import url("relian-thunar.css");\n' >> "$HOME/.config/gtk-3.0/gtk.css"

mkdir -p "$backup"
for d in "${dirs[@]}"; do [ -e "$HOME/.config/$d" ] && cp -a "$HOME/.config/$d" "$backup/"; done
echo "backup: $backup"

for d in "${dirs[@]}"; do rsync -a "$root/config/$d/" "$HOME/.config/$d/"; done
chmod +x "$HOME"/.config/hypr/scripts/* "$HOME"/.config/hypr/UserScripts/*.sh "$HOME"/.config/hypr/initial-boot.sh 2>/dev/null || true

# reload what can be reloaded live
hyprctl reload >/dev/null 2>&1 || true
pkill -SIGUSR2 waybar 2>/dev/null || true
swaync-client -R >/dev/null 2>&1 && swaync-client -rs >/dev/null 2>&1 || true
echo "done. Waybar layout/style are chosen with SUPER+ALT+B / SUPER+CTRL+B; theme with SUPER+SHIFT+CTRL+SPACE."

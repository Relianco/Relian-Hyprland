#!/usr/bin/env bash
# Copy this repo's config into ~/.config (nothing is deleted), after a timestamped backup.
# Run it (1) after pulling changes, and (2) once after Hyprland has restarted on hyprland.lua, so the
# Lua-aware scripts replace the old-format ones. Usage: tools/install-live.sh
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
backup="$HOME/.config-backup-relian-$(date +%Y%m%d-%H%M%S)"
dirs=(hypr waybar rofi wallust kitty swaync)


mkdir -p "$backup"
for d in "${dirs[@]}"; do [ -e "$HOME/.config/$d" ] && cp -a "$HOME/.config/$d" "$backup/"; done
echo "backup: $backup"

for d in "${dirs[@]}"; do rsync -a "$root/config/$d/" "$HOME/.config/$d/"; done

# GTK: the "relian" theme = adw-gtk3-dark + wallust colours + Thunar styling. wallust rewrites its gtk.css on every theme
# change, and GTK re-reads a *theme* live (ThemeSelect.sh flicks the setting), which it never does for ~/.config/gtk-3.0/gtk.css.
theme="$HOME/.local/share/themes/relian"
mkdir -p "$theme/gtk-3.0" "$HOME/.config/gtk-3.0"
cp "$root/config/gtk-theme/relian/index.theme" "$theme/"
cp "$root/config/gtk-theme/relian/gtk-3.0/relian-thunar.css" "$theme/gtk-3.0/"
[ -f "$theme/gtk-3.0/gtk.css" ] || cp "$root/config/gtk-theme/relian/gtk-3.0/gtk.css.fallback" "$theme/gtk-3.0/gtk.css"
gsettings set org.gnome.desktop.interface gtk-theme relian 2>/dev/null || true
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then sed -i 's/^gtk-theme-name=.*/gtk-theme-name=relian/' "$HOME/.config/gtk-3.0/settings.ini"; fi
# a hard-coded accent in gtk.css would override the theme (the user stylesheet wins): back it up once, then drop it
gtkcss="$HOME/.config/gtk-3.0/gtk.css"
if [ -f "$gtkcss" ] && grep -qE '^@define-color accent_|relian-(colors|thunar)\.css' "$gtkcss"; then
  [ -f "$gtkcss.relian-bak" ] || cp "$gtkcss" "$gtkcss.relian-bak"
  sed -i -E '/^@define-color accent_/d; /relian-(colors|thunar)\.css/d' "$gtkcss"
fi
chmod +x "$HOME"/.config/hypr/scripts/* "$HOME"/.config/hypr/UserScripts/*.sh "$HOME"/.config/hypr/initial-boot.sh 2>/dev/null || true

# reload what can be reloaded live
hyprctl reload >/dev/null 2>&1 || true
pkill -SIGUSR2 waybar 2>/dev/null || true
swaync-client -R >/dev/null 2>&1 && swaync-client -rs >/dev/null 2>&1 || true
echo "done. Waybar layout/style are chosen with SUPER+ALT+B / SUPER+CTRL+B; theme with SUPER+SHIFT+CTRL+SPACE."

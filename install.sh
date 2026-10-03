#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Installer / updater. Safe to run again at any time: it backs up first, never deletes anything,
# and leaves your own settings (UserConfigs, monitors, workspaces) alone unless you pass --force.
#
#   ./install.sh              install or update into ~/.config, then reload what can be reloaded live
#   ./install.sh --files-only copy files only (no gsettings, no reloads); used by the tests
#   ./install.sh --force      also overwrite your own settings files with the repo defaults
#   ./install.sh --help
set -eu

root=$(cd "$(dirname "$0")" && pwd)
files_only=0
force=0
for arg in "$@"; do
  case "$arg" in
    --files-only) files_only=1 ;;
    --force) force=1 ;;
    -h | --help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

say() { printf '\033[1;35m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

# --- 1. dependencies: report, never install (package names differ per distro) ---------------------
need=(Hyprland waybar rofi kitty swaync wallust jq rsync awww wl-paste cliphist wlogout grim slurp thunar hypridle hyprlock)
missing=()
for c in "${need[@]}"; do command -v "$c" >/dev/null 2>&1 || missing+=("$c"); done
if [ "${#missing[@]}" -gt 0 ]; then
  warn "missing commands: ${missing[*]}"
  warn "install them: ./config/hypr/scripts/InstallPackages.sh core tools extras   (Arch/Manjaro, uses paru or yay); continuing anyway"
fi

# optional: the bar and menus still load without these, but the matching button or key does nothing
opt=(pamixer playerctl brightnessctl btop pavucontrol swappy powerprofilesctl blueman-manager nm-connection-editor notify-send python3 ttfx claudebar codexbar)
omissing=()
for c in "${opt[@]}"; do command -v "$c" >/dev/null 2>&1 || omissing+=("$c"); done
[ "${#omissing[@]}" -gt 0 ] && warn "optional, missing: ${omissing[*]} (volume/brightness/media keys, mixer, screenshots, performance button, screensaver, agent usage)"

# --- 2. backup ---------------------------------------------------------------------------------------
# Only the desktop pieces we manage. nvim, Qt (qt5ct/qt6ct/Kvantum) etc. are yours and are never touched.
dirs=(hypr waybar rofi wallust kitty swaync wlogout fastfetch cava btop swappy quickshell ags)
backup="$HOME/.config-backup-relian-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup" "$HOME/.config"
for d in "${dirs[@]}"; do [ -e "$HOME/.config/$d" ] && cp -a "$HOME/.config/$d" "$backup/"; done
say "backup of your current config: $backup"

# --- 3. copy configs -----------------------------------------------------------------------------------
# User-owned files: copied only if missing (so your edits survive updates), unless --force.
user_owned=(--exclude 'UserConfigs/' --exclude 'monitors.lua' --exclude 'workspaces.lua')
for d in "${dirs[@]}"; do
  [ -d "$root/config/$d" ] || continue
  mkdir -p "$HOME/.config/$d"
  if [ "$d" = hypr ] && [ "$force" = 0 ]; then
    rsync -a "${user_owned[@]}" "$root/config/hypr/" "$HOME/.config/hypr/"
    rsync -a --ignore-existing "$root/config/hypr/" "$HOME/.config/hypr/"
  else
    rsync -a "$root/config/$d/" "$HOME/.config/$d/"
  fi
done
chmod +x "$HOME"/.config/hypr/scripts/* "$HOME"/.config/hypr/UserScripts/*.sh "$HOME"/.config/hypr/initial-boot.sh 2>/dev/null || true
# keep only the newest version marker (the in-session update check compares against it)
newest=$(ls "$HOME"/.config/hypr/v[0-9]* 2>/dev/null | sort -V | tail -1)
for v in "$HOME"/.config/hypr/v[0-9]*; do [ -e "$v" ] && [ "$v" != "$newest" ] && rm -f "$v"; done
say "configs copied to ~/.config"

# --- 4. wallpapers -------------------------------------------------------------------------------------
mkdir -p "$HOME/Pictures/wallpapers"
cp -rn "$root/wallpapers/." "$HOME/Pictures/wallpapers/" 2>/dev/null || true
cur="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
mkdir -p "$(dirname "$cur")"
if [ ! -f "$cur" ]; then
  first=$(find "$HOME/Pictures/wallpapers" -maxdepth 2 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | sort | head -1)
  [ -n "$first" ] && cp "$first" "$cur"
fi

# --- 5. defaults that should exist but must not clobber your choices ---------------------------------------
wb="$HOME/.config/waybar"
[ -e "$wb/config" ] || ln -sf "configs/[TOP] Omarchy" "$wb/config"
[ -e "$wb/style.css" ] || ln -sf "style/[Omarchy] Minimal.css" "$wb/style.css"

# --- 6. GTK theme "relian": adw-gtk3-dark + the wallust colours + Thunar styling -------------------------------
# wallust rewrites its gtk.css on every theme change; GTK re-reads a *theme* live, but never ~/.config/gtk-3.0/gtk.css.
theme="$HOME/.local/share/themes/relian"
mkdir -p "$theme/gtk-3.0" "$HOME/.config/gtk-3.0"
cp "$root/config/gtk-theme/relian/index.theme" "$theme/"
cp "$root/config/gtk-theme/relian/gtk-3.0/relian-thunar.css" "$theme/gtk-3.0/"
[ -f "$theme/gtk-3.0/gtk.css" ] || cp "$root/config/gtk-theme/relian/gtk-3.0/gtk.css.fallback" "$theme/gtk-3.0/gtk.css"
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
  sed -i 's/^gtk-theme-name=.*/gtk-theme-name=relian/' "$HOME/.config/gtk-3.0/settings.ini"
else
  printf '[Settings]\ngtk-theme-name=relian\ngtk-application-prefer-dark-theme=1\n' > "$HOME/.config/gtk-3.0/settings.ini"
fi
# a hard-coded accent in gtk.css would override the theme (the user stylesheet wins): back it up once, then drop it
gtkcss="$HOME/.config/gtk-3.0/gtk.css"
if [ -f "$gtkcss" ] && grep -qE '^@define-color accent_|relian-(colors|thunar)\.css' "$gtkcss"; then
  [ -f "$gtkcss.relian-bak" ] || cp "$gtkcss" "$gtkcss.relian-bak"
  sed -i -E '/^@define-color accent_/d; /relian-(colors|thunar)\.css/d' "$gtkcss"
fi
# GTK4 apps (pavucontrol, ...) read gtk-4.0/gtk.css from the theme, but a user ~/.config/gtk-4.0/gtk.css that re-imports
# adw-gtk3 (the usual symlink) would put the stock blue/grey back on top: back it up once and drop it
mkdir -p "$theme/gtk-4.0" "$HOME/.config/gtk-4.0"
[ -f "$theme/gtk-4.0/gtk.css" ] || printf '@import url("file:///usr/share/themes/adw-gtk3-dark/gtk-4.0/gtk.css");\n' > "$theme/gtk-4.0/gtk.css"
ln -sf gtk.css "$theme/gtk-4.0/gtk-dark.css"   # GTK4 prefers gtk-dark.css when the dark preference is on
g4="$HOME/.config/gtk-4.0/gtk.css"
if [ -L "$g4" ] && readlink "$g4" | grep -q adw-gtk3; then
  [ -e "$g4.relian-bak" ] || mv "$g4" "$g4.relian-bak"
  rm -f "$g4"
fi
[ -f "$HOME/.config/gtk-4.0/settings.ini" ] && sed -i 's/^gtk-theme-name=.*/gtk-theme-name=relian/' "$HOME/.config/gtk-4.0/settings.ini"
[ "$files_only" = 1 ] || gsettings set org.gnome.desktop.interface gtk-theme relian 2>/dev/null || true

# --- 7. first theme: only if none was ever chosen -----------------------------------------------------------
state="${XDG_CACHE_HOME:-$HOME/.cache}/hypr-dots-theme"
if [ ! -f "$state" ] && command -v wallust >/dev/null 2>&1; then
  if [ "$files_only" = 1 ]; then
    THEME_NO_RELOAD=1 THEME_NO_SEQUENCES=1 "$HOME/.config/hypr/scripts/ThemeSelect.sh" --set "Catppuccin" >/dev/null 2>&1 || true
  else
    "$HOME/.config/hypr/scripts/ThemeSelect.sh" --set "Catppuccin" >/dev/null 2>&1 || true
  fi
  say "default theme applied (change it any time with SUPER+SHIFT+CTRL+SPACE)"
fi

# --- 8. reload what can be reloaded without logging out ------------------------------------------------------
if [ "$files_only" = 0 ]; then
  hyprctl reload >/dev/null 2>&1 || true
  pkill -SIGUSR2 waybar 2>/dev/null || true
  swaync-client -R >/dev/null 2>&1 && swaync-client -rs >/dev/null 2>&1 || true
fi

say "done."
cat <<EOF

Next steps
  - Log out and start Hyprland again (>= 0.55) so it loads ~/.config/hypr/hyprland.lua.
    A running session that started on the old hyprlang config cannot switch to Lua without a restart.
  - Optional: 'yay -S ttfx' for the screensaver; 'sudo tools/install-login.sh' for the SDDM login theme (preview: tools/preview-login.sh).
  - SUPER+H shows every keybind, SUPER+SPACE the main menu, SUPER+SHIFT+CTRL+SPACE the theme carousel.
  - Docs: docs/KEYBINDINGS.md and docs/CUSTOMIZING.md
EOF

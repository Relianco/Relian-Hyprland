#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Installs the packages this setup uses (Arch/Manjaro; paru, falling back to yay). Only missing ones are installed.
#   InstallPackages.sh [group ...] [--dry-run] [--yes]
# Groups (default: core tools):
#   core    what the desktop needs to start        tools   what keys and bar buttons call (volume, media, mixer, ...)
#   extras  screensaver (ttfx), Claude/Codex usage bar, performance mode, animated wallpapers (mpvpaper)
#   looks   animated wallpapers (mpvpaper), Colloid icons and a few cursor sets
#   all     everything above
set -u
declare -A G
G[core]="hyprland waybar rofi kitty swaync wlogout hypridle hyprlock wallust awww wl-clipboard cliphist grim slurp jq rsync thunar ttf-jetbrains-mono-nerd adw-gtk-theme"
G[tools]="pamixer playerctl brightnessctl btop pavucontrol swappy blueman networkmanager libnotify python"
G[extras]="ttfx claudebar codexbar power-profiles-daemon mpvpaper"
G[looks]="mpvpaper papirus-icon-theme colloid-icon-theme-git colloid-catppuccin-theme-git colloid-cursors-git bibata-cursor-theme phinger-cursors catppuccin-cursors-mocha capitaine-cursors vimix-cursors"
G[all]="${G[core]} ${G[tools]} ${G[extras]} ${G[looks]}"

dry=0; yes=0; groups=()
for a in "$@"; do
  case "$a" in
    --dry-run) dry=1 ;; --yes|-y) yes=1 ;;
    -h|--help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    core|tools|extras|looks|all) groups+=("$a") ;;
    *) echo "unknown argument: $a (try --help)" >&2; exit 2 ;;
  esac
done
[ "${#groups[@]}" -gt 0 ] || groups=(core)

helper=""; for h in paru yay; do command -v "$h" >/dev/null 2>&1 && { helper=$h; break; }; done
[ -n "$helper" ] || [ "$dry" = 1 ] || { echo "needs paru or yay (AUR packages)" >&2; exit 1; }

want=(); for g in "${groups[@]}"; do for p in ${G[$g]}; do want+=("$p"); done; done
missing=(); for p in "${want[@]}"; do pacman -Qq "$p" >/dev/null 2>&1 || missing+=("$p"); done
missing=($(printf '%s\n' "${missing[@]}" | awk '!s[$0]++'))   # dedupe, keep order

if [ "${#missing[@]}" -eq 0 ]; then echo "everything in [${groups[*]}] is already installed"; exit 0; fi
echo "to install (${helper:-paru}): ${missing[*]}"
[ "$dry" = 1 ] && exit 0
args=(-S --needed); [ "$yes" = 1 ] && args+=(--noconfirm)
exec "$helper" "${args[@]}" "${missing[@]}"

#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Install the "relian" SDDM login theme (needs root: writes /usr/share/sddm/themes and /etc/sddm.conf).
#   sudo tools/install-login.sh                 build in your current theme's colours and make SDDM use it
#   sudo tools/install-login.sh "Tokyo Night"   or pick a theme by name
#   sudo tools/install-login.sh --restore       put your previous /etc/sddm.conf back
# Preview first, without root and without touching anything:  tools/preview-login.sh
# Your old /etc/sddm.conf is saved once as /etc/sddm.conf.relian-bak. Only the [Theme] Current= line changes.
# (RELIAN_THEMES_DIR / RELIAN_SDDM_CONF override the two paths; the tests use that to run without root.)
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
themes_dir=${RELIAN_THEMES_DIR:-/usr/share/sddm/themes}
conf=${RELIAN_SDDM_CONF:-/etc/sddm.conf}
bak="$conf.relian-bak"

if [ -z "${RELIAN_THEMES_DIR:-}${RELIAN_SDDM_CONF:-}" ] && [ "$(id -u)" -ne 0 ]; then
  echo "needs root: run  sudo $0 $*" >&2; exit 1
fi

if [ "${1:-}" = "--restore" ]; then
  [ -f "$bak" ] || { echo "no backup at $bak" >&2; exit 1; }
  cp "$bak" "$conf"; echo "restored $conf from $bak"; exit 0
fi

# the theme name defaults to the *invoking user's* current carousel theme (root has its own, empty, home)
theme=${1:-}
if [ -z "$theme" ]; then
  uhome=$(getent passwd "${SUDO_USER:-$(id -un)}" | cut -d: -f6)
  theme=$(cat "$uhome/.cache/hypr-dots-theme" 2>/dev/null || true)
fi
case "$theme" in "" | "Wallpaper colours") theme=Catppuccin ;; esac

out="$themes_dir/relian"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
python3 "$root/tools/build-sddm-theme.py" "$tmp/relian" --theme "$theme"
[ -f "$tmp/relian/Main.qml" ] || { echo "theme build failed, nothing changed" >&2; exit 1; }
mkdir -p "$themes_dir"; rm -rf "$out"; cp -r "$tmp/relian" "$out"; chmod -R a+rX "$out"

touch "$conf"
[ -f "$bak" ] || cp "$conf" "$bak"
if grep -q '^\[Theme\]' "$conf"; then
  if sed -n '/^\[Theme\]/,/^\[/p' "$conf" | grep -q '^Current='; then
    sed -i '/^\[Theme\]/,/^\[/ s/^Current=.*/Current=relian/' "$conf"
  else
    sed -i '/^\[Theme\]/a Current=relian' "$conf"
  fi
else
  printf '\n[Theme]\nCurrent=relian\n' >> "$conf"
fi
echo "installed: $out  ($theme colours)"
echo "SDDM now uses it at the next login screen (log out, or reboot). Undo with: sudo $0 --restore"
echo "To recolour later (e.g. after you change theme), run this script again."

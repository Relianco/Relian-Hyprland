#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Shared bits for the bar popups (Calendar.sh, VolumeMenu.sh, WifiMenu.sh, BluetoothMenu.sh): theme colours and a meter.
# Source it:  . "$HOME/.config/hypr/scripts/PopupLib.sh"
popup_theme="$HOME/.config/rofi/config-popup.rasi"
_colors="$HOME/.config/rofi/wallust/colors-rofi.rasi"
_color() { sed -n "s/^$1: *\(#[0-9A-Fa-f]\{6\}\).*/\1/p" "$_colors" 2>/dev/null | head -1; }
accent=$(_color active-background); accent_fg=$(_color active-foreground); fg=$(_color normal-foreground)
: "${accent:=#89B4FA}" "${accent_fg:=#000000}" "${fg:=#CDD6F4}"

# meter PERCENT [WIDTH] -> pango: filled blocks in the accent colour, the rest dim (like the Claude/Codex usage tooltip)
meter() {
  local p=$1 w=${2:-28} f i out="" empty=""
  [ "$p" -gt 100 ] && p=100; [ "$p" -lt 0 ] && p=0
  f=$(( (p * w + 50) / 100 ))
  for ((i = 0; i < f; i++)); do out+="█"; done
  for ((i = f; i < w; i++)); do empty+="█"; done
  printf '<span foreground="%s">%s</span><span alpha="22%%">%s</span>' "$accent" "$out" "$empty"
}

# esc TEXT -> pango-safe text
esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }   # (bash's own ${s//</&lt;} treats & in the replacement as the match)

# the rofi keys the popups share: move rofi's own Left/Right/Up/Down bindings out of the way so they can be used as custom keys
popup_keys=(-kb-move-char-back "Control+b" -kb-move-char-forward "Control+f" -kb-row-up "Control+p" -kb-row-down "Control+n"
            -kb-page-prev "" -kb-page-next "" -kb-row-first "")

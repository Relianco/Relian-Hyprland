#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Theme picker/carousel (modeled on Omarchy's theme menu). Colors are applied live through wallust,
# so Hyprland borders, Waybar, rofi, kitty, swaync and hyprlock all follow.
#   ThemeSelect.sh           open the carousel: LEFT/RIGHT cycle + preview, ENTER keep, ESC revert
#   ThemeSelect.sh --next    apply the next theme right now (--prev for previous)
#   ThemeSelect.sh --list    print the theme names
#   ThemeSelect.sh --set N   apply a theme by name (e.g. "Tokyo Night" or "Wallpaper colours")
# Env: WALLUST_CONFIG_DIR (use another wallust config dir), THEME_NO_RELOAD=1 (only write the color files),
#      THEME_NO_SEQUENCES=1 (do not recolor open terminals)

WALL="Wallpaper colours"
schemes_dir="${WALLUST_CONFIG_DIR:-$HOME/.config/wallust}/colorschemes"
state="${XDG_CACHE_HOME:-$HOME/.cache}/hypr-dots-theme"
rofi_theme="$HOME/.config/rofi/config-omarchy-launcher.rasi"
current_wallpaper="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

wallust_cmd=(wallust)
[ -n "${WALLUST_CONFIG_DIR:-}" ] && wallust_cmd+=(-d "$WALLUST_CONFIG_DIR")
[ -n "${THEME_NO_RELOAD:-}${THEME_NO_SEQUENCES:-}" ] && wallust_cmd+=(-s)   # do not push colors to open terminals (tests/demo)

# "omarchy-tokyo-night.json" -> "Tokyo Night"
pretty() { local n=${1%.json}; n=${n#omarchy-}; n=${n//-/ }; local out="" w; for w in $n; do out+="${w^} "; done; echo "${out% }"; }
file_for() { local f; for f in "$schemes_dir"/omarchy-*.json; do [ "$(pretty "$(basename "$f")")" = "$1" ] && { basename "$f" .json; return; }; done; }

themes=("$WALL")
while IFS= read -r f; do themes+=("$(pretty "$(basename "$f")")"); done < <(find -L "$schemes_dir" -maxdepth 1 -name 'omarchy-*.json' 2>/dev/null | sort)
[ "${#themes[@]}" -gt 1 ] || { echo "no themes in $schemes_dir" >&2; exit 1; }

current() { cat "$state" 2>/dev/null || echo "$WALL"; }
index_of() { local i; for i in "${!themes[@]}"; do [ "${themes[i]}" = "$1" ] && { echo "$i"; return; }; done; echo 0; }

apply() { # apply <theme name>
  local name=$1
  if [ "$name" = "$WALL" ]; then
    if [ -f "$current_wallpaper" ]; then "${wallust_cmd[@]}" -q run "$current_wallpaper" || return 1
    else echo "no current wallpaper at $current_wallpaper" >&2; return 1; fi
  else
    local scheme; scheme=$(file_for "$name"); [ -n "$scheme" ] || { echo "unknown theme: $name" >&2; return 1; }
    "${wallust_cmd[@]}" -q cs "$scheme.json" || return 1   # ".json": a bare name is a prefix match ("catppuccin" vs "catppuccin-latte")
  fi
  mkdir -p "$(dirname "$state")"; printf '%s' "$name" > "$state"
  [ -n "${THEME_NO_RELOAD:-}" ] && return 0
  hyprctl reload >/dev/null 2>&1          # re-reads the Lua config, which re-reads wallust-hyprland.lua
  pkill -SIGUSR2 waybar 2>/dev/null       # waybar reloads its css
  swaync-client -rs >/dev/null 2>&1 &     # swaync css
  return 0
}

step() { # step <+1|-1>  -> apply neighbor theme
  local i; i=$(index_of "$(current)"); i=$(( (i + $1 + ${#themes[@]}) % ${#themes[@]} ))
  apply "${themes[i]}" && echo "${themes[i]}"
}

case "${1:-}" in
  --list) printf '%s\n' "${themes[@]}"; exit 0 ;;
  --next) step 1; exit ;;
  --prev) step -1; exit ;;
  --set)  apply "${2:?theme name}"; exit ;;
esac

# --- carousel -----------------------------------------------------------------------------------
pkill rofi 2>/dev/null
original=$(current); sel=$(index_of "$original"); shown=$original
# rofi's default bindings for Left/Right/Up/Down are moved to Ctrl+B/F/P/N below so the carousel can use the arrows
while true; do
  choice=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -i -format i -selected-row "$sel" -no-custom \
    -theme "$rofi_theme" -theme-str 'window { width: 420px; } entry { placeholder: "󰏘  Theme"; }' \
    -mesg "←/→ cycle and preview   Enter keep   Esc revert" \
    -kb-move-char-back "Control+b" -kb-move-char-forward "Control+f" -kb-row-up "Control+p" -kb-row-down "Control+n" \
    -kb-custom-1 "Left,Up" -kb-custom-2 "Right,Down")
  rc=$?
  case $rc in
    10) sel=$(( (sel - 1 + ${#themes[@]}) % ${#themes[@]} )); shown=${themes[sel]}; apply "$shown" ;;
    11) sel=$(( (sel + 1) % ${#themes[@]} )); shown=${themes[sel]}; apply "$shown" ;;
    0)  sel=$choice; [ "${themes[sel]}" = "$shown" ] || apply "${themes[sel]}"; exit 0 ;;
    *)  [ "$shown" = "$original" ] || apply "$original"; exit 0 ;;
  esac
done

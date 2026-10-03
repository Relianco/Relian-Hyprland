#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# Searchable list of the active keybinds in rofi.
# Reads the live binds from Hyprland (hyprctl binds -j), so user overrides/unbinds are reflected automatically.
# Binds show their `description` (set it with hl.bind(..., { description = "..." })).

# kill yad to not interfere with this binds
pkill yad || true

# check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

rofi_theme="$HOME/.config/rofi/config-keybinds.rasi"
msg='Browse only: clicking or pressing Enter does nothing'

display_keybinds=$(hyprctl binds -j | jq -r '
  def bit($n): ((.modmask / $n | floor) % 2) == 1;
  .[]
  | ([ (if bit(64) then "SUPER" else empty end),
       (if bit(4)  then "CTRL"  else empty end),
       (if bit(8)  then "ALT"   else empty end),
       (if bit(1)  then "SHIFT" else empty end) ]
     + [ (if .key != "" then .key elif .keycode != 0 then "code:\(.keycode)" else "(keycode)" end) ]
     | join("+")) as $combo
  | "\($combo)  —  \(if .description != "" then .description else "(no description)" end)"
')

# check for any keybinds to display
if [[ -z "$display_keybinds" ]]; then
  echo "no keybinds found."
  exit 1
fi

# use rofi to display the keybinds
printf '%s\n' "$display_keybinds" | rofi -dmenu -i -config "$rofi_theme" -mesg "$msg"

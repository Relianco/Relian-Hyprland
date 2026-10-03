#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# For disabling touchpad.
# Edit the Touchpad_Device in ~/.config/hypr/configs/Laptops.lua according to your system
# use hyprctl devices to get your system touchpad device name
# source https://github.com/hyprwm/Hyprland/discussions/4283?sort=new#discussioncomment-8648109

notif="$HOME/.config/swaync/images/ja.png"

export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"
TOUCHPAD_DEVICE=$(sed -n 's/^local Touchpad_Device = "\(.*\)"/\1/p' "$HOME/.config/hypr/configs/Laptops.lua")

enable_touchpad() {
    printf "true" >"$STATUS_FILE"
    notify-send -u low -i $notif  " Enabling" " touchpad"
    hyprctl eval "hl.device({ name = \"$TOUCHPAD_DEVICE\", enabled = true })"
}

disable_touchpad() {
    printf "false" >"$STATUS_FILE"
    notify-send -u low -i $notif " Disabling" " touchpad"
    hyprctl eval "hl.device({ name = \"$TOUCHPAD_DEVICE\", enabled = false })"
}

if ! [ -f "$STATUS_FILE" ]; then
  enable_touchpad
else
  if [ $(cat "$STATUS_FILE") = "true" ]; then
    disable_touchpad
  elif [ $(cat "$STATUS_FILE") = "false" ]; then
    enable_touchpad
  fi
fi

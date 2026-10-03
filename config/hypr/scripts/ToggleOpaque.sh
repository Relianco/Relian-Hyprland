#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# Toggle "always opaque" on the focused window (SUPER + CTRL + O).
# `hyprctl setprop ...` no longer exists in recent Hyprland, so: read the current value, then set the opposite
# with the Lua dispatcher (Lua config) or `dispatch setprop` (old hyprlang session). Works in both.

cur=$(hyprctl getprop active opaque 2>/dev/null | head -1)
case "$cur" in true | 1) new=0 ;; *) new=1 ;; esac

if ! hyprctl dispatch "hl.dsp.window.set_prop({ prop = \"opaque\", value = \"$new\" })" 2>&1 | grep -qx ok; then
  hyprctl dispatch setprop active opaque "$new" >/dev/null 2>&1
fi

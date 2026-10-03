#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# Toggle "always opaque" on the focused window (SUPER + CTRL + O). For kitty also toggles kitty's own transparency,
# which Hyprland cannot touch (needs allow_remote_control in kitty.conf; applies to kitty windows opened after that was added).
# `hyprctl setprop ...` no longer exists in recent Hyprland, so: read the current value, then set the opposite
# with the Lua dispatcher (Lua config) or `dispatch setprop` (old hyprlang session). Works in both.

cur=$(hyprctl getprop active opaque 2>/dev/null | head -1)
case "$cur" in true | 1) new=0 ;; *) new=1 ;; esac

if ! hyprctl dispatch "hl.dsp.window.set_prop({ prop = \"opaque\", value = \"$new\" })" 2>&1 | grep -qx ok; then
  hyprctl dispatch setprop active opaque "$new" >/dev/null 2>&1
fi

# kitty draws its own transparent background (background_opacity), so set that too. Any kitty-based window works
# (class kitty, agent, ...); for a window that is not kitty the socket does not exist and this does nothing.
pid=$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid // empty')
default=$(sed -n 's/^background_opacity[[:space:]]\+\([0-9.]\+\).*/\1/p' "$HOME/.config/kitty/kitty.conf" | head -1)
[ "$new" = 1 ] && target=1 || target=${default:-0.9}
[ -n "$pid" ] && kitten @ --to "unix:@kitty-$pid" set-background-opacity "$target" >/dev/null 2>&1
exit 0

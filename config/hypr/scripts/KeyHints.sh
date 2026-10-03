#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# Quick cheat sheet (SUPER + H): every keybind with a description, in the same rofi style as the other menus.
# Type to search (matches key, description or notes); Esc closes. For the *live* binds use SUPER + SHIFT + K.

rofi_theme="$HOME/.config/rofi/config-omarchy-menu.rasi"

# key | description | notes
rows=(
  'SUPER + SHIFT + K' 'Searchable Keybinds' '(Search all Keybinds via rofi)'
  'SUPER + SHIFT + E' 'Relian Hyprland Settings Menu' ''
  'SUPER + enter' Terminal '(kitty)'
  'SUPER + SHIFT + enter' 'DropDown Terminal' 'SUPER Q to close'
  'SUPER + B' 'Launch Browser' '(Default browser)'
  'SUPER + A' 'Desktop Overview' '(AGS - if opted to install)'
  'SUPER + D' 'Application Launcher' '(also SUPER ALT SPACE, like Omarchy)'
  'SUPER + E' 'Open File Manager' '(Thunar)'
  'SUPER + S' 'Google Search using rofi' '(rofi)'
  'SUPER + Q' 'close active window' '(not kill)'
  'SUPER + SHIFT + Q' 'kills an active window' '(kill)'
  'SUPER + ALT + mouse scroll up/down' 'Desktop Zoom' 'Desktop Magnifier'
  'SUPER + ALT + V' 'Clipboard Manager' '(cliphist)'
  'SUPER + W' 'Choose wallpaper' '(Wallpaper Menu)'
  'SUPER + SHIFT + W' 'Choose wallpaper effects' '(imagemagick + swww)'
  'CTRL + ALT + W' 'Random wallpaper' '(via swww)'
  'SUPER + CTRL + ALT + B' 'Hide/UnHide Waybar' waybar
  'SUPER + CTRL + B' 'Choose waybar styles' '(waybar styles)'
  'SUPER + ALT + B' 'Choose waybar layout' '(waybar layout)'
  'SUPER + ALT + R' 'Reload Waybar swaync Rofi' 'CHECK NOTIFICATION FIRST!!!'
  'SUPER + SHIFT + N' 'Launch Notification Panel' 'swaync Notification Center'
  'SUPER + Print' screenshot '(grim)'
  'SUPER + SHIFT + Print' 'screenshot region' '(grim + slurp)'
  'SUPER + SHIFT + S' 'screenshot region' '(swappy)'
  'SUPER + CTRL + Print' 'screenshot timer 5 secs ' '(grim)'
  'SUPER + CTRL + SHIFT + Print' 'screenshot timer 10 secs ' '(grim)'
  'ALT + Print' 'Screenshot active window' 'active window only'
  'CTRL + ALT + P' power-menu '(wlogout)'
  'CTRL + ALT + L' 'screen lock' '(hyprlock)'
  'CTRL + ALT + Del' 'Hyprland Exit' '(NOTE: Hyprland Will exit immediately)'
  'SUPER + SHIFT + F' Fullscreen 'Toggles to full screen'
  'SUPER + CTRL + F' 'Fake Fullscreen' 'Toggles to fake full screen'
  'SUPER + ALT + L' 'Toggle Dwindle | Master Layout' 'Hyprland Layout'
  'SUPER + SPACE' 'Main menu (Relian settings)' '(Omarchy: SUPER SPACE)'
  'SUPER + SHIFT + CTRL + SPACE' 'Theme carousel' '(LEFT/RIGHT cycle + live preview, ENTER keep, ESC revert)'
  'SUPER + CTRL + ALT + S' 'Toggle the screensaver' '(starts after 5 minutes idle; any key ends it)'
  'SUPER + CTRL + A' 'Ask an AI agent' '(Enter: Claude Code, Shift+Enter: Codex; also the waybar robot icon)'
  'SUPER + - / =' 'Resize window narrower / wider' '(+SHIFT: shorter/taller, +ALT: small steps, +CTRL: big steps)'
  'SUPER + T' 'Toggle float' 'single window'
  'SUPER + ALT + T' 'Toggle all windows to float' 'all windows'
  'SUPER + ALT + O' 'Toggle Blur' 'normal or less blur'
  'SUPER + CTRL + O' 'Toggle Opaque ON or OFF' 'on active window only'
  'SUPER + SHIFT + A' 'Animations Menu' 'Choose Animations via rofi'
  'SUPER + CTRL + R' 'Rofi Themes Menu' 'Choose Rofi Themes via rofi'
  'SUPER + CTRL + SHIFT + R' 'Rofi Themes Menu v2' 'Choose Rofi Themes via Theme Selector (modified)'
  'SUPER + SHIFT + G' 'Gamemode! All animations OFF or ON' toggle
  'SUPER + ALT + E' 'Rofi Emoticons' Emoticon
  'SUPER + H' 'Launch this Quick Cheat Sheet' ''
)

pkill rofi 2>/dev/null

# three columns, padded so the list lines up (the rofi theme uses a monospace font)
for ((i = 0; i < ${#rows[@]}; i += 3)); do
  printf '%-30s %-46s %s\n' "${rows[i]}" "${rows[i + 1]}" "${rows[i + 2]}"
done | rofi -dmenu -i -no-custom -theme "$rofi_theme" \
  -theme-str 'window { width: 1300px; } entry { placeholder: "󰌌  Search keybinds..."; } listview { lines: 16; }' \
  -mesg "Type to search   Esc to close   (live binds: SUPER + SHIFT + K)"

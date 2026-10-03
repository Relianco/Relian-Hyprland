# Keybindings

Generated from the Lua config by `tools/gen-keybindings-doc.py` (a test fails if this file is out of date).
`SUPER` is the Windows key. In your running session, **SUPER + H** shows this list, **SUPER + SHIFT + K** searches the live binds.

## Default binds

Source: `config/hypr/configs/Keybinds.lua`

### Common shortcuts

| Keys | What it does |
|---|---|
| `SUPER + ALT + SPACE` | app launcher (Omarchy style) |
| `SUPER + D` | app launcher |
| `SUPER + B` | open default browser |
| `SUPER + A` | desktop overview |
| `SUPER + Return` | Open terminal |
| `SUPER + E` | file manager |

### FEATURES / EXTRAS

| Keys | What it does |
|---|---|
| `SUPER + H` | help / cheat sheet |
| `SUPER + ALT + R` | refresh bar and menus |
| `SUPER + ALT + E` | emoji menu |
| `SUPER + S` | web search |
| `SUPER + CTRL + S` | window switcher |
| `SUPER + ALT + O` | toggle blur |
| `SUPER + SHIFT + G` | toggle game mode |
| `SUPER + ALT + L` | toggle master/dwindle layout |
| `SUPER + ALT + V` | clipboard manager |
| `SUPER + CTRL + R` | rofi theme selector |
| `SUPER + CTRL + SHIFT + R` | rofi theme selector (modified) |
| `SUPER + SHIFT + F` | fullscreen |
| `SUPER + CTRL + F` | maximize window |
| `SUPER + SPACE` | main menu (Omarchy style) |
| `SUPER + CTRL + ALT + S` | toggle the screensaver on/off |
| `SUPER + SHIFT + CTRL + SPACE` | theme carousel (Omarchy style) |
| `SUPER + SHIFT + CTRL + I` | icon theme carousel |
| `SUPER + SHIFT + CTRL + C` | cursor theme carousel |
| `SUPER + CTRL + A` | ask an AI agent (Claude / Codex) |
| `SUPER + T` | Float current window |
| `SUPER + ALT + T` | Float all windows |
| `SUPER + SHIFT + Return` | DropDown terminal |

### Desktop zooming or magnifier

| Keys | What it does |
|---|---|
| `SUPER + ALT + mouse_down` | zoom in |
| `SUPER + ALT + mouse_up` | zoom out |

### Waybar / Bar related

| Keys | What it does |
|---|---|
| `SUPER + CTRL + ALT + B` | toggle waybar on/off |
| `SUPER + CTRL + B` | waybar styles menu |
| `SUPER + ALT + B` | waybar layout menu |

### Night light toggle (Hyprsunset)

| Keys | What it does |
|---|---|
| `SUPER + N` | toggle night light |

### FEATURES / EXTRAS (UserScripts)

| Keys | What it does |
|---|---|
| `SUPER + SHIFT + M` | online music |
| `SUPER + W` | select wallpaper |
| `SUPER + SHIFT + W` | wallpaper effects |
| `CTRL + ALT + W` | random wallpaper |
| `SUPER + CTRL + O` | toggle active window opacity |
| `SUPER + SHIFT + K` | search keybinds |
| `SUPER + SHIFT + A` | animations menu |
| `SUPER + SHIFT + O` | change oh-my-zsh theme |
| `ALT_L + SHIFT_L` | switch keyboard layout globally |
| `SHIFT_L + ALT_L` | switch keyboard layout per-window |
| `SUPER + ALT + C` | calculator |
| `SUPER + CTRL + F9` | move workspace to left monitor |
| `SUPER + CTRL + F10` | move workspace to right monitor |
| `SUPER + CTRL + F11` | move workspace to up monitor |
| `SUPER + CTRL + F12` | move workspace to down monitor |
| `CTRL + ALT + Delete` | exit Hyprland |
| `SUPER + Q` | close active window |
| `SUPER + SHIFT + Q` | Terminate active process |
| `CTRL + ALT + L` | lock screen |
| `CTRL + ALT + P` | powermenu |
| `SUPER + SHIFT + N` | notification panel |
| `SUPER + SHIFT + E` | Quick settings menu |

### Master Layout

| Keys | What it does |
|---|---|
| `SUPER + CTRL + D` | remove master |
| `SUPER + I` | add master |
| `SUPER + CTRL + Return` | swap with master |

### Dwindle Layout

| Keys | What it does |
|---|---|
| `SUPER + SHIFT + I` | toggle split (dwindle) |
| `SUPER + P` | toggle pseudo (dwindle) |
| `SUPER + M` | set split ratio 0.3 |

### Cycle windows; if floating bring to top

| Keys | What it does |
|---|---|
| `ALT + tab` | cycle next window, bring to top |

### Special Keys / Hot Keys

| Keys | What it does |
|---|---|
| `xf86audioraisevolume` | volume up |
| `xf86audiolowervolume` | volume down |
| `xf86AudioMicMute` | toggle mic mute |
| `xf86audiomute` | toggle mute |
| `xf86Sleep` | sleep |
| `xf86Rfkill` | airplane mode |
| `xf86AudioPause` | pause |
| `xf86AudioPlay` | play |
| `xf86AudioNext` | next track |
| `xf86AudioPrev` | previous track |
| `xf86audiostop` | stop |
| `SUPER + Print` | screenshot now |
| `SUPER + SHIFT + Print` | screenshot (area) |
| `SUPER + CTRL + Print` | screenshot in 5s |
| `SUPER + CTRL + SHIFT + Print` | screenshot in 10s |
| `ALT + Print` | screenshot active window |
| `SUPER + SHIFT + S` | screenshot (swappy) |

### Resize windows

| Keys | What it does |
|---|---|
| `SUPER + SHIFT + left` | resize left (-50) |
| `SUPER + SHIFT + right` | resize right (+50) |
| `SUPER + SHIFT + up` | resize up (-50) |
| `SUPER + SHIFT + down` | resize down (+50) |

### Move windows

| Keys | What it does |
|---|---|
| `SUPER + CTRL + left` | move window left |
| `SUPER + CTRL + right` | move window right |
| `SUPER + CTRL + up` | move window up |
| `SUPER + CTRL + down` | move window down |

### Swap windows

| Keys | What it does |
|---|---|
| `SUPER + ALT + left` | swap window left |
| `SUPER + ALT + right` | swap window right |
| `SUPER + ALT + up` | swap window up |
| `SUPER + ALT + down` | swap window down |
| `SUPER + G` | toggle group |

### Navigate within a group

| Keys | What it does |
|---|---|
| `SUPER + Tab` | Change Group Forward |
| `SUPER + CTRL + tab` | change active in group |
| `SUPER + SHIFT + Tab` | Change Group Back |

### Move window into/out of group

| Keys | What it does |
|---|---|
| `SUPER + CTRL + K` | Move left into group |
| `SUPER + CTRL + L` | Move Right into group |
| `SUPER + CTRL + H` | Move active out of group |

### Move focus with mainMod + arrow keys

| Keys | What it does |
|---|---|
| `SUPER + left` | focus left |
| `SUPER + right` | focus right |
| `SUPER + up` | focus up |
| `SUPER + down` | focus down |

### Workspaces related

| Keys | What it does |
|---|---|
| `SUPER + tab` | next workspace |
| `SUPER + SHIFT + tab` | previous workspace |

### Special workspace

| Keys | What it does |
|---|---|
| `SUPER + SHIFT + U` | move to special workspace |
| `SUPER + U` | toggle special workspace |

### Switch workspaces with mainMod + [0-9]

| Keys | What it does |
|---|---|
| `SUPER + 1` | workspace 1 |
| `SUPER + 2` | workspace 2 |
| `SUPER + 3` | workspace 3 |
| `SUPER + 4` | workspace 4 |
| `SUPER + 5` | workspace 5 |
| `SUPER + 6` | workspace 6 |
| `SUPER + 7` | workspace 7 |
| `SUPER + 8` | workspace 8 |
| `SUPER + 9` | workspace 9 |
| `SUPER + 0` | workspace 10 |
| `SUPER + SHIFT + 1` | move to workspace 1 |
| `SUPER + SHIFT + 2` | move to workspace 2 |
| `SUPER + SHIFT + 3` | move to workspace 3 |
| `SUPER + SHIFT + 4` | move to workspace 4 |
| `SUPER + SHIFT + 5` | move to workspace 5 |
| `SUPER + SHIFT + 6` | move to workspace 6 |
| `SUPER + SHIFT + 7` | move to workspace 7 |
| `SUPER + SHIFT + 8` | move to workspace 8 |
| `SUPER + SHIFT + 9` | move to workspace 9 |
| `SUPER + SHIFT + 0` | move to workspace 10 |
| `SUPER + SHIFT + bracketleft` | move to previous workspace |
| `SUPER + SHIFT + bracketright` | move to next workspace |
| `SUPER + CTRL + 1` | move silently to workspace 1 |
| `SUPER + CTRL + 2` | move silently to workspace 2 |
| `SUPER + CTRL + 3` | move silently to workspace 3 |
| `SUPER + CTRL + 4` | move silently to workspace 4 |
| `SUPER + CTRL + 5` | move silently to workspace 5 |
| `SUPER + CTRL + 6` | move silently to workspace 6 |
| `SUPER + CTRL + 7` | move silently to workspace 7 |
| `SUPER + CTRL + 8` | move silently to workspace 8 |
| `SUPER + CTRL + 9` | move silently to workspace 9 |
| `SUPER + CTRL + 0` | move silently to workspace 10 |
| `SUPER + CTRL + bracketleft` | move silently to previous workspace |
| `SUPER + CTRL + bracketright` | move silently to next workspace |
| `SUPER + mouse_down` | next workspace |
| `SUPER + mouse_up` | previous workspace |
| `SUPER + period` | next workspace |
| `SUPER + comma` | previous workspace |
| `SUPER + mouse:272` | move window |
| `SUPER + mouse:273` | resize window |

## Your binds

Source: `config/hypr/UserConfigs/UserKeybinds.lua`

### E.g.

| Keys | What it does |
|---|---|
| `SUPER + ` | resize narrower |
| `SUPER + ` | resize wider |
| `SUPER + SHIFT + ` | resize shorter |
| `SUPER + SHIFT + ` | resize taller |
| `SUPER + CTRL + SHIFT + M` | toggle mic mute |

## Laptop keys

Source: `config/hypr/configs/Laptops.lua`

| Keys | What it does |
|---|---|
| `xf86KbdBrightnessDown` | (no description) |
| `xf86KbdBrightnessUp` | (no description) |
| `xf86Launch1` | (no description) |
| `xf86Launch3` | (no description) |
| `xf86Launch4` | (no description) |
| `xf86MonBrightnessDown` | (no description) |
| `xf86MonBrightnessUp` | (no description) |
| `xf86TouchpadToggle` | (no description) |
| `SUPER + F6` | (no description) |
| `SUPER + SHIFT + F6` | (no description) |
| `SUPER + CTRL + F6` | (no description) |
| `SUPER + ALT + F6` | (no description) |
| `ALT + F6` | (no description) |

## Resize (generated in a loop)

In `UserConfigs/UserKeybinds.lua`, on the `-` and `=` keys (Omarchy's layout):

| Keys | What it does |
|---|---|
| `SUPER + -` / `SUPER + =` | narrower / wider by 100px |
| `SUPER + SHIFT + -` / `=` | shorter / taller by 100px |
| add `ALT` | small steps (25px) |
| add `CTRL` | big steps (300px) |

# Customizing

Where things live, how to change them, and what to do when something looks wrong. Paths are relative to `~/.config/hypr/`
unless stated otherwise. Re-running `./install.sh` never overwrites the files marked **yours**.

## How the config is organized

`hyprland.lua` loads small modules in this order. Later ones win, so put your changes in the `UserConfigs/` ones.

| File | What it holds | |
|---|---|---|
| `configs/Keybinds.lua` | the default keybinds | defaults |
| `configs/WindowRules.lua` | window and layer rules (tags, floats, sizes, opacity) | defaults |
| `configs/SystemSettings.lua` | input, layout, gestures, misc | defaults |
| `configs/Startup_Apps.lua` | apps started at login | defaults |
| `UserConfigs/UserKeybinds.lua` | your keybinds, including the resize keys | **yours** |
| `UserConfigs/WindowRules.lua` | your window rules | **yours** |
| `UserConfigs/UserSettings.lua` | any `hl.config({...})` override | **yours** |
| `UserConfigs/UserDecorations.lua` | gaps, borders, rounding (0), blur, shadow (off), colors | **yours** |
| `UserConfigs/UserAnimations.lua` | animations (presets in `animations/`) | **yours** |
| `UserConfigs/UserGaming.lua` | VRR and the Wine/Proton/gamescope fixes | **yours** |
| `UserConfigs/01-UserDefaults.conf` | default terminal, file manager, editor | **yours** (plain key/value so scripts can read it) |
| `monitors.lua`, `workspaces.lua` | monitors and workspace rules | **yours** |

Hyprland's own docs for every function used here: <https://wiki.hypr.land/Configuring/Start/>.

## Common changes

**Add a keybind** (`UserConfigs/UserKeybinds.lua`):

```lua
hl.bind("SUPER + Z", hl.dsp.exec_cmd("firefox"), { description = "open Firefox" })
```

Always add a `description`: the help menu (`SUPER+H`) and the bind search (`SUPER+SHIFT+K`) show it. To replace a default,
unbind it first (the key text is case-sensitive and must match): `hl.unbind("SUPER + Return")`.

**Add a window rule** (`UserConfigs/WindowRules.lua`):

```lua
hl.window_rule({ match = { class = "^(mpv)$" }, float = true, size = { "monitor_h*1.2", "monitor_h*0.7" } })
```

Size floating windows from `monitor_h`, not `monitor_w`: percentages of the width become huge on a 5120px ultrawide.

**Change the gaps / borders** (`UserConfigs/UserDecorations.lua`): `gaps_in`, `gaps_out`, `border_size`. Rounding is 0 and
shadows are off on purpose (flat look).

**Change the default apps**: edit `UserConfigs/01-UserDefaults.conf` (`$term`, `$files`, `EDITOR`). Keybinds and Waybar read it.

**Monitors** (`monitors.lua`): `hyprctl monitors` lists them. The default is the highest refresh rate on every output. nwg-displays
writes hyprlang files, not Lua, so edit this file by hand. Example:
`hl.monitor({ output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = 1 })`.

**A single window centered on a workspace** (optional): in `configs/SystemSettings.lua`,
`layout = { single_window_aspect_ratio = { 16, 9 } }` centers a lone window at that ratio instead of stretching it across the
whole monitor. It only affects windows that are alone on their workspace.

**Gaming**: `UserConfigs/UserGaming.lua` sets VRR for games and the Wine/WoW fullscreen fixes. Add your own game classes there
(`hyprctl activewindow` shows a window's class).

## Themes and colors

- **Switch theme**: `SUPER+SHIFT+CTRL+SPACE`. Left/Right cycle with a live preview, Enter keeps, Esc puts back what you had.
  `ThemeSelect.sh --next`, `--prev`, `--set "Nord"` and `--list` do the same from a terminal or a bind.
- **Wallpaper colors**: the first entry in the carousel derives the palette from your current wallpaper (`SUPER+W` to change it).
- **How it works**: [wallust](https://codeberg.org/explosion-mental/wallust) takes a color scheme, fills the templates in
  `~/.config/wallust/templates/`, and writes the results to Hyprland, Waybar, rofi, kitty, swaync and the `relian` GTK theme.
  GTK apps pick the change up live because GTK re-reads a *theme* when the theme setting flips (a GTK stylesheet file is never
  re-read).
- **Add a theme**: drop a wallust color scheme (JSON with `special` and `color0`–`color15`) into
  `config/wallust/colorschemes/omarchy-<name>.json` and re-run `./install.sh`. `tools/omarchy-themes-to-wallust.py` regenerates
  the bundled ones from Omarchy's palettes (it skips light themes on purpose).
- **Readable highlights on any theme**: the rofi template picks light or dark text for each highlight color, and a test checks
  the contrast of all themes.

## Bar, menus and notifications

- **Waybar**: layouts are in `~/.config/waybar/configs/`, styles in `style/`. `SUPER+CTRL+B` picks a style, `SUPER+ALT+B` a layout.
  The default pair is `[TOP] Omarchy` and `[Omarchy] Minimal`. The center shows network speed, clock, weather and temperatures
  (`scripts/SensorTemps.sh` finds the sensors by name, so it keeps working if the hwmon numbers change).
- **Agent usage icon**: needs `claudebar` and `codexbar` (AUR). Without them the icon still shows and the tooltip says what to
  install. Hovering shows each limit with a meter and its reset time. Click asks an agent (`AgentPrompt.sh`); right-click opens
  Claude, middle-click opens Codex.
- **Performance and do-not-disturb buttons**: two icons left of the tray (`scripts/BarToggles.sh`). The gauge flips the power
  profile between performance and balanced (needs `power-profiles-daemon`), the bell silences notifications (swaync). Lit = on, dim = off.
- **rofi**: every menu imports `config-omarchy-menu.rasi` (list menus) or `config-omarchy-launcher.rasi` (launcher/input boxes).
  The launcher searches app names (and generic names like "File Manager") and orders results by how often you launch them.
- **Notifications** (swaync) and **power menu** (wlogout) have their own stylesheets in `config/swaync` and `config/wlogout`;
  both follow the theme colors.

## Screensaver and login screen

- **Screensaver**: after 5 minutes idle (hypridle) every monitor shows the Relian logo as ASCII art with a random
  [ttfx](https://github.com/ChrisBuilds/terminaltexteffects) effect; any key or focus change ends it. Needs `ttfx` (`yay -S ttfx`).
  `SUPER+CTRL+ALT+S` turns it on/off, the main menu can preview it. Add your own art as `.txt` files in
  `~/.config/hypr/branding/large/` (42+ rows, big screens) or `small/`; `tools/make-ascii-logo.py --all` regenerates the bundled set.
- **Login screen** (SDDM): a dim, animated version of the screensaver art sits behind the password box (a brighter band sweeps across it and the art changes every ~25s). `tools/preview-login.sh` shows it without touching anything; `sudo tools/install-login.sh [Theme]` installs it
  (backs up `/etc/sddm.conf` first), `sudo tools/install-login.sh --restore` undoes it. Colors follow the theme you pick.

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| New terminals open full screen instead of tiling | kitty cached a "maximized" state. `remember_window_size no` in `kitty.conf` stops it (already set); delete `~/.cache/kitty/main.json` once. |
| `SUPER+CTRL+O` doesn't change a terminal | kitty needs `allow_remote_control socket-only` and `dynamic_background_opacity yes` (both set), and the terminal must have been started after that. Open a new one. |
| Thunar still shows old colors after a theme switch | Thunar is a daemon that kept the old stylesheet from before the GTK theme existed. Run `thunar -q` once, then open it again. |
| `hyprctl dispatch workspace 2` etc. error out | Under the Lua config dispatchers are Lua expressions: `hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'`; settings changes use `hyprctl eval 'hl.config({ ... })'`. |
| The running session ignores `hyprland.lua` | It started on the old hyprlang config. Hyprland picks the format at startup: log out and back in. |
| A script reports "unknown request" for `setprop` | Removed in recent Hyprland. Use the `hl.dsp.window.set_prop(...)` dispatcher (see `scripts/ToggleOpaque.sh`). |
| A rofi menu warns about overlapping key bindings | A custom key collides with one of rofi's own. Free the default first (see `ThemeSelect.sh` and `AgentPrompt.sh` for examples). |

## Trying a change without risk

- `tests/run.sh` checks the config, scripts, themes and installer in seconds and touches nothing of yours.
- `tests/demo-nested.sh` runs the whole config in a window so you can look before you restart.
- `./install.sh` makes a timestamped backup of everything it touches (`~/.config-backup-relian-*`).

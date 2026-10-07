# Changelog

## 2.4.0

The Lua rewrite and the Omarchy-style look.

### Added
- **Screensaver**: randomized ASCII-art Relian logo with ttfx effects on every monitor (idle 5 min, `SUPER+CTRL+ALT+S` toggle), and a minimal **SDDM login theme** (`tools/install-login.sh`). Adapted from Omarchy (MIT, see NOTICE).
- Waybar **performance mode** and **do-not-disturb** buttons (`BarToggles.sh`).
- Hyprland config converted to **Lua** (Hyprland ≥ 0.55): `hyprland.lua` plus small modules; your settings in `UserConfigs/`.
- **Theme carousel** (`SUPER+SHIFT+CTRL+SPACE`): 16 dark themes with live preview; Waybar, rofi, kitty, swaync, hyprlock and
  GTK apps recolor together. A GTK theme, `relian`, follows the palette live.
- **Waybar** layout and style modeled on Omarchy, with network speed, CPU/GPU/drive temperatures and a Claude + Codex usage icon
  (hover for limits, click to ask an agent).
- One shared **rofi** look for the launcher and every menu, plus a searchable help menu (`SUPER+H`).
- Flat styling for kitty, swaync (notifications) and wlogout (power menu); Thunar and other GTK3 apps follow the theme.
- `SUPER+-` / `SUPER+=` resize keys (Omarchy's set), `SUPER+CTRL+A` agent prompt, `SUPER+CTRL+O` opacity toggle that also
  covers terminals.
- `install.sh` (installer/updater), `tests/run.sh` (config checks), `tests/demo-nested.sh` (try it in a window),
  generated `docs/KEYBINDINGS.md`.

### Changed
- Square corners, flat borders (no shadow glow), 5/10px gaps.
- Floating-window sizes are based on monitor height so ultrawide screens get sensible windows.
- App launcher matches names only and ranks by how often you use an app.
- `hyprctl dispatch`/`keyword` calls in scripts replaced with Lua dispatchers and `hyprctl eval`.

### Fixed
- Browsers dimming when unfocused: browser windows are now solid (`1.0 override`) and `dim_inactive` is off, so a video no longer darkens when the mouse leaves the window.
- Terminals opening full screen instead of tiling (kitty was restoring a cached "maximized" state).
- The opacity toggle (it used `hyprctl setprop`, which no longer exists).
- Rofi key-binding overlap warnings; unreadable highlighted rows on some themes; `getoption`-based toggles under Lua.

### Removed
- The old multi-distro installers, upstream release/update scripts and community files; light themes; rainbow borders.

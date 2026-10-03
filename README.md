# Relian-Hyprland

Hyprland dotfiles for an ultrawide desktop: a **Lua** Hyprland config (Hyprland ≥ 0.55) with an
Omarchy-style look and feel. A modified fork of the upstream Hyprland-Dots project
(GPL-3.0; credit and list of changes in [NOTICE](NOTICE)).

## What you get

| | |
|---|---|
| **Config** | `config/hypr/hyprland.lua` + modules in `configs/` and `UserConfigs/` (your overrides go in `UserConfigs/`) |
| **Waybar** | Omarchy-style bar (`[TOP] Omarchy`): workspace dots, network speed, clock, weather, CPU/GPU/drive temps, Claude/Codex usage icon |
| **Launcher / menus** | rofi, themed like Omarchy. `Super+Alt+Space` apps, `Super+Space` main menu, `Super+H` searchable help |
| **Themes** | `Super+Shift+Ctrl+Space` theme carousel (Omarchy's themes via wallust). Left/Right cycles with live preview |
| **Agents** | Waybar robot icon: hover for Claude/Codex usage, click to ask an agent (`Super+Ctrl+A`) |
| **Terminal / notifications** | kitty and swaync styled to match |

## Key bindings you'll use

`Super+Return` terminal · `Super+D` / `Super+Alt+Space` launcher · `Super+Space` main menu · `Super+H` help ·
`Super+Q` close · `Super+T` float · `Super+- / =` resize (add Shift/Alt/Ctrl for vertical / small / big) ·
`Super+Shift+K` search the live binds

## Install

```bash
git clone https://github.com/Relianco/Relian-Hyprland.git
cd Relian-Hyprland
./copy.sh          # backs up and copies config/ into ~/.config
```

Needs Hyprland ≥ 0.55, waybar, rofi, kitty, swaync, wallust, jq, and a JetBrainsMono Nerd Font.
For the agent icon: `yay -S claudebar codexbar`, then run `claude` / `codex login` once.

## Try it without logging out

```bash
tests/demo-nested.sh      # runs the config in a window (nested Hyprland); close the window to quit
```

## Tests

```bash
tests/run.sh              # config validation, script syntax, theme/contrast checks, regression guards
```

## License

GPL-3.0. See [LICENSE.md](LICENSE.md) and [NOTICE](NOTICE).

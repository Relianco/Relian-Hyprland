# Relian-Hyprland

A complete Hyprland desktop for an ultrawide monitor, written in **Lua** (Hyprland ≥ 0.55) with an
[Omarchy](https://omarchy.org)-style look and feel: flat square windows, one accent color that follows
the theme, a minimal top bar, and a launcher/menu system that all look like they belong together.

It is a modified fork of an existing dotfiles project (GPL-3.0). See [NOTICE](NOTICE) for the credit and the
list of changes.

## What you get

| Piece | What it is |
|---|---|
| **Hyprland config** | `config/hypr/hyprland.lua` plus small modules. Your own settings live in `UserConfigs/` and survive updates. |
| **Theme carousel** | `SUPER+SHIFT+CTRL+SPACE`: cycle 16 dark themes with live preview (Left/Right), Enter keeps, Esc reverts. Borders, Waybar, rofi, kitty, notifications, the lock screen and GTK apps all recolor together, no restart. Plus "Wallpaper colours", which derives the palette from your wallpaper. |
| **Bar** | Omarchy-style Waybar: workspace dots, network speed, clock, weather, CPU/GPU/drive temperatures, Claude + Codex usage icon, tray, audio, battery. |
| **Launcher and menus** | One shared rofi look. `SUPER+ALT+SPACE` apps, `SUPER+SPACE` main menu, `SUPER+ALT+V` clipboard, plus emoji, calculator, wallpaper grid and power menu. `SUPER+H` is a searchable list of every keybind. |
| **AI agents** | The robot icon in the bar: hover for your Claude and Codex usage, click (or `SUPER+CTRL+A`) to type a prompt and open it in a floating terminal. |
| **Apps styled to match** | kitty (terminal), swaync (notifications), wlogout (power menu), Thunar and other GTK3 apps. |
| **Screensaver and login** | Idle screensaver with the Relian logo in randomized 90s ASCII art on every monitor, and a minimal SDDM login theme. See [docs/CUSTOMIZING.md](docs/CUSTOMIZING.md). |
| **Tests** | `tests/run.sh` validates the whole config in a few seconds, without touching your session. |

## Requirements

- **Hyprland ≥ 0.55** (the Lua config needs it), Waybar, rofi (Wayland build), kitty, swaync, wlogout, hypridle, hyprlock
- **wallust** (colors), **swww** (wallpaper daemon), `wl-clipboard`, `cliphist`, `grim`, `slurp`, `jq`, `rsync`
- A **JetBrainsMono Nerd Font**, the `adw-gtk3` GTK theme, and Thunar (or any file manager)
- Optional: `ttfx` for the screensaver (`yay -S ttfx`); `power-profiles-daemon` for the bar's performance button; `claudebar` and `codexbar` for the usage icon (`yay -S claudebar codexbar`, then log in with `claude` / `codex login` once)

On Arch, most of it is one command:

```bash
sudo pacman -S hyprland waybar rofi kitty swaync wlogout hypridle hyprlock wallust swww wl-clipboard cliphist \
  grim slurp jq rsync thunar ttf-jetbrains-mono-nerd adw-gtk-theme
```

## Install

```bash
git clone https://github.com/Relianco/Relian-Hyprland.git
cd Relian-Hyprland
./install.sh
```

`install.sh` is safe to run again at any time. It backs up what it touches (`~/.config-backup-relian-<date>`), copies the
configs, installs the GTK theme and wallpapers, applies a first theme, and reloads what can be reloaded live. It never deletes
files, and it leaves your own settings (`UserConfigs/`, `monitors.lua`, `workspaces.lua`) alone unless you pass `--force`.

Then **log out and start Hyprland again**: a session that started on an old hyprlang config can't switch to Lua without a restart.

## Using it

The keys you'll use every day (the full list is [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md), or press `SUPER+H`):

| Keys | |
|---|---|
| `SUPER+Return` | terminal |
| `SUPER+ALT+SPACE` / `SUPER+D` | app launcher |
| `SUPER+SPACE` | main menu (settings, themes, waybar, wallpapers) |
| `SUPER+SHIFT+CTRL+SPACE` | theme carousel |
| `SUPER+H` / `SUPER+SHIFT+K` | searchable help / search the live binds |
| `SUPER+Q` / `SUPER+T` | close / float |
| `SUPER+-` and `SUPER+=` | resize (add Shift for height, Alt for small steps, Ctrl for big) |
| `SUPER+CTRL+A` | ask an AI agent |
| `SUPER+CTRL+O` | toggle window transparency (terminals too) |

## Make it yours

Everything you're likely to change is in `~/.config/hypr/UserConfigs/` (keybinds, startup apps, window rules, decorations,
animations, gaming rules) and `monitors.lua`. [docs/CUSTOMIZING.md](docs/CUSTOMIZING.md) explains where each thing lives,
how to add a keybind, a window rule or a theme, and how to fix the usual problems.

## Try it without logging out

```bash
tests/demo-nested.sh      # runs the config in a window (a nested Hyprland); close the window to quit
```

Handy before you commit to a restart. It uses a throwaway home directory and strips the startup entries that would touch
your real session.

## Updating

```bash
cd Relian-Hyprland && git pull && ./install.sh
```

`config/hypr/scripts/RelianDotsUpdate.sh` checks GitHub for a newer version and runs the same two steps for you.

## Tests

```bash
tests/run.sh
```

Checks that the Lua config loads, every animation preset and menu theme parses, every script passes `bash -n`, every
theme applies and stays readable (contrast), the install works in an empty home directory, and a set of regression guards
for bugs we hit along the way. Nothing in it touches your real credentials or session.

## Repository layout

```
install.sh                 installer / updater
config/hypr/               Hyprland (hyprland.lua, configs/, UserConfigs/, scripts/, animations/, ...)
config/waybar/             bar layouts (configs/) and styles (style/)
config/rofi/               launcher and menu themes (config-*.rasi)
config/wallust/            color templates and the 16 theme color schemes
config/gtk-theme/          the "relian" GTK theme (adw-gtk3-dark + wallust colors)
config/{kitty,swaync,wlogout,...}   styled apps
docs/                      keybindings (generated) and the customizing guide
tests/                     run.sh (checks) and demo-nested.sh (try it in a window)
tools/                     generators (theme converter, keybinding doc)
wallpapers/                starter wallpapers
```

## License

GPL-3.0 ([LICENSE.md](LICENSE.md)). Credit and the list of changes are in [NOTICE](NOTICE).

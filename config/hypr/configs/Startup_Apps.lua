-- /* ---- Relian-Hyprland ---- */
-- Commands and apps to be executed at launch (vendor defaults)
local D = require("UserConfigs.01-UserDefaults")
local scriptsDir, UserScripts = D.scriptsDir, D.UserScripts
local wallDIR = D.home .. "/Pictures/wallpapers"
local SwwwRandom = UserScripts .. "/WallpaperAutoChange.sh"
local livewallpaper = ""

hl.on("hyprland.start", function()
    local function run(cmd) hl.exec_cmd(cmd) end

    -- wallpaper stuff
    run("awww-daemon --format xrgb")
    -- run('mpvpaper "*" -o "load-scripts=no no-audio --loop" ' .. livewallpaper)
    -- run(SwwwRandom .. " " .. wallDIR) -- random wallpaper switcher every 30 minutes

    -- Startup
    run("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    run("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    run(scriptsDir .. "/KeybindsLayoutInit.sh")

    -- Drop Down terminal. See Bug#810 (upstream issue #810)
    run(D.home .. "/.config/hypr/scripts/Dropterminal.sh kitty &")

    -- Polkit (Polkit Gnome / KDE)
    run(scriptsDir .. "/Polkit.sh")

    -- startup apps
    run("nm-applet --indicator")
    run("nm-tray") -- For ubuntu
    run("swaync")
    -- run("ags")
    -- run("blueman-applet")
    -- run("rog-control-center")
    run("waybar")
    run("qs -c overview") -- Quickshell Overview

    -- Clipboard manager
    run("wl-paste --type text --watch cliphist store")
    run("wl-paste --type image --watch cliphist store")

    -- hypridle for hyprlock
    run("hypridle")

    -- Resume Hyprsunset if state is "on" from previous session
    run(scriptsDir .. "/Hyprsunset.sh init")

    -- Persistent wallpaper
    -- run("awww-daemon --format xrgb && awww img $HOME/Pictures/wallpapers/mecha-nostalgia.png")
    -- Gnome polkit for NixOS
    -- run(scriptsDir .. "/Polkit-NixOS.sh")
    -- xdg-desktop-portal-hyprland (should be auto starting. However, you can force to start)
    -- run(scriptsDir .. "/PortalHyprland.sh")

    run("blueman-applet")
    run("ags")
end)

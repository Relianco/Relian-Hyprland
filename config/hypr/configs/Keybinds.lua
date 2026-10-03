-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Default keybinds (Lua). https://wiki.hypr.land/Configuring/Basics/Binds/
local D = require("UserConfigs.01-UserDefaults")
local scriptsDir, UserScripts, term, files = D.scriptsDir, D.UserScripts, D.term, D.files

-- zoom(m): multiply cursor zoom by m (never below 1x). Replaces the old hyprctl getoption/awk pipeline.
local function zoom(m)
    return function()
        local f = tonumber(hl.get_config("cursor.zoom_factor")) or 1
        if f < 1 then f = 1 end
        hl.config({ cursor = { zoom_factor = math.max(1, f * m) } })
    end
end
-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
-- Default Keybinds
-- visit https://wiki.hyprland.org/Configuring/Binds/ for more info

-- /* ---- ✴️ Variables ✴️ ---- */  #

-- settings for User defaults apps - set your default terminal and file manager on this file

--### STANDAR ####
-- Common shortcuts
--bindr = $mainMod, $mainMod_L, exec, pkill rofi || rofi -show drun -modi drun,filebrowser,run,window # Super Key to Launch rofi menu
-- App launcher: Omarchy uses SUPER+ALT+SPACE; SUPER+D kept as an alias
local launcher = hl.dsp.exec_cmd("pkill rofi || rofi -show drun -show-icons -theme " .. os.getenv("HOME") .. "/.config/rofi/config-omarchy-launcher.rasi")
hl.bind("SUPER + ALT + SPACE", launcher, { description = "app launcher (Omarchy style)" })
hl.bind("SUPER + D", launcher, { description = "app launcher" })
hl.bind("SUPER + B", hl.dsp.exec_cmd("xdg-open \"https://\""), { description = "open default browser" })
hl.bind("SUPER + A", hl.dsp.exec_cmd(scriptsDir .. "/OverviewToggle.sh"), { description = "desktop overview" })  -- toggles quickshell or ags overview (tries QS first, falls back to AGS)
--bindd = $mainMod, A, ags overview, exec, pkill rofi || true && ags -t 'overview' # desktop overview (if installed)
--bindd = $mainMod, A, Quickshell overview, global, quickshell:overviewToggle # desktop overview (if installed)
hl.bind("SUPER + Return", hl.dsp.exec_cmd(term), { description = "Open terminal" })
hl.bind("SUPER + E", hl.dsp.exec_cmd(files), { description = "file manager" })

-- FEATURES / EXTRAS
hl.bind("SUPER + H", hl.dsp.exec_cmd(scriptsDir .. "/KeyHints.sh"), { description = "help / cheat sheet" })
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd(scriptsDir .. "/Refresh.sh"), { description = "refresh bar and menus" })
hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd(scriptsDir .. "/RofiEmoji.sh"), { description = "emoji menu" })
hl.bind("SUPER + S", hl.dsp.exec_cmd(scriptsDir .. "/RofiSearch.sh"), { description = "web search" })
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("rofi -show window"), { description = "window switcher" })
hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd(scriptsDir .. "/ChangeBlur.sh"), { description = "toggle blur" })
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd(scriptsDir .. "/GameMode.sh"), { description = "toggle game mode" })
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd(scriptsDir .. "/ChangeLayout.sh"), { description = "toggle master/dwindle layout" })
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd(scriptsDir .. "/ClipManager.sh"), { description = "clipboard manager" })
hl.bind("SUPER + CTRL + R", hl.dsp.exec_cmd(scriptsDir .. "/RofiThemeSelector.sh"), { description = "rofi theme selector" })
hl.bind("SUPER + CTRL + SHIFT + R", hl.dsp.exec_cmd("pkill rofi || true && " .. scriptsDir .. "/RofiThemeSelector-modified.sh"), { description = "rofi theme selector (modified)" })

hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "fullscreen" })
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "maximize window" })
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(scriptsDir .. "/Kool_Quick_Settings.sh"), { description = "main menu (Omarchy style)" })
hl.bind("SUPER + SHIFT + CTRL + SPACE", hl.dsp.exec_cmd(scriptsDir .. "/ThemeSelect.sh"), { description = "theme carousel (Omarchy style)" })
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }), { description = "Float current window" })
hl.bind("SUPER + ALT + T", function()
    for _, w in ipairs(hl.get_workspace_windows(hl.get_active_workspace())) do
        hl.dispatch(hl.dsp.window.float({ window = w, action = "set" }))
    end
end, { description = "Float all windows" })
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd(scriptsDir .. "/Dropterminal.sh " .. term), { description = "DropDown terminal" })

-- Desktop zooming or magnifier
hl.bind("SUPER + ALT + mouse_down", zoom(2.0), { description = "zoom in" })
hl.bind("SUPER + ALT + mouse_up", zoom(1 / 2.0), { description = "zoom out" })

-- Waybar / Bar related
hl.bind("SUPER + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"), { description = "toggle waybar on/off" })
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd(scriptsDir .. "/WaybarStyles.sh"), { description = "waybar styles menu" })
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd(scriptsDir .. "/WaybarLayout.sh"), { description = "waybar layout menu" })

-- Night light toggle (Hyprsunset)
hl.bind("SUPER + N", hl.dsp.exec_cmd(scriptsDir .. "/Hyprsunset.sh toggle"), { description = "toggle night light" })

-- FEATURES / EXTRAS (UserScripts)
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd(UserScripts .. "/RofiBeats.sh"), { description = "online music" })
hl.bind("SUPER + W", hl.dsp.exec_cmd(UserScripts .. "/WallpaperSelect.sh"), { description = "select wallpaper" })
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(UserScripts .. "/WallpaperEffects.sh"), { description = "wallpaper effects" })
hl.bind("CTRL + ALT + W", hl.dsp.exec_cmd(UserScripts .. "/WallpaperRandom.sh"), { description = "random wallpaper" })
hl.bind("SUPER + CTRL + O", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }), { description = "toggle active window opacity" })
hl.bind("SUPER + SHIFT + K", hl.dsp.exec_cmd(scriptsDir .. "/KeyBinds.sh"), { description = "search keybinds" })
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd(scriptsDir .. "/Animations.sh"), { description = "animations menu" })
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd(UserScripts .. "/ZshChangeTheme.sh"), { description = "change oh-my-zsh theme" })
hl.bind("ALT_L + SHIFT_L", hl.dsp.exec_cmd(scriptsDir .. "/SwitchKeyboardLayout.sh"), { locked = true, non_consuming = true, description = "switch keyboard layout globally" })
hl.bind("SHIFT_L + ALT_L", hl.dsp.exec_cmd(scriptsDir .. "/Tak0-Per-Window-Switch.sh"), { locked = true, non_consuming = true, description = "switch keyboard layout per-window" })
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd(UserScripts .. "/RofiCalc.sh"), { description = "calculator" })

-- Move current workspaces to monitors (left right up or down)
hl.bind("SUPER + CTRL + F9", hl.dsp.workspace.move({ monitor = "left" }), { description = "move workspace to left monitor" })
hl.bind("SUPER + CTRL + F10", hl.dsp.workspace.move({ monitor = "right" }), { description = "move workspace to right monitor" })
hl.bind("SUPER + CTRL + F11", hl.dsp.workspace.move({ monitor = "up" }), { description = "move workspace to up monitor" })
hl.bind("SUPER + CTRL + F12", hl.dsp.workspace.move({ monitor = "down" }), { description = "move workspace to down monitor" })


--### SYSTEM ####
hl.bind("CTRL + ALT + Delete", hl.dsp.exit(), { description = "exit Hyprland" })
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "close active window" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd(scriptsDir .. "/KillActiveProcess.sh"), { description = "Terminate active process" })
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"), { description = "lock screen" })
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd(scriptsDir .. "/Wlogout.sh"), { description = "powermenu" })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "notification panel" })
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd(scriptsDir .. "/Kool_Quick_Settings.sh"), { description = "Quick settings menu" })

-- Master Layout
hl.bind("SUPER + CTRL + D", hl.dsp.layout("removemaster"), { description = "remove master" })
hl.bind("SUPER + I", hl.dsp.layout("addmaster"), { description = "add master" })
-- NOTE: J/K bindings are set dynamically by scripts/KeybindsLayoutInit.sh and scripts/ChangeLayout.sh
-- (we intentionally do not bind them statically here to avoid conflicts across layouts)
-- bindd = $mainMod, J, cycle next, layoutmsg, cyclenext
-- bindd = $mainMod, K, cycle previous, layoutmsg, cycleprev
hl.bind("SUPER + CTRL + Return", hl.dsp.layout("swapwithmaster"), { description = "swap with master" })

-- Dwindle Layout
hl.bind("SUPER + SHIFT + I", hl.dsp.layout("togglesplit"), { description = "toggle split (dwindle)" })
hl.bind("SUPER + P", hl.dsp.window.pseudo(), { description = "toggle pseudo (dwindle)" })

-- Works on either layout (Master or Dwindle)
hl.bind("SUPER + M", hl.dsp.layout("splitratio 0.3"), { description = "set split ratio 0.3" })


-- Cycle windows; if floating bring to top
hl.bind("ALT + tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "cycle next window, bring to top" })

-- Special Keys / Hot Keys
hl.bind("xf86audioraisevolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --inc"), { locked = true, repeating = true, description = "volume up" })
hl.bind("xf86audiolowervolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --dec"), { locked = true, repeating = true, description = "volume down" })
hl.bind("xf86AudioMicMute", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle-mic"), { locked = true, description = "toggle mic mute" })
hl.bind("xf86audiomute", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle"), { locked = true, description = "toggle mute" })
hl.bind("xf86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { locked = true, description = "sleep" })
hl.bind("xf86Rfkill", hl.dsp.exec_cmd(scriptsDir .. "/AirplaneMode.sh"), { locked = true, description = "airplane mode" })

-- media controls using keyboards
hl.bind("xf86AudioPause", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { locked = true, description = "pause" })
hl.bind("xf86AudioPlay", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { locked = true, description = "play" })
hl.bind("xf86AudioNext", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --nxt"), { locked = true, description = "next track" })
hl.bind("xf86AudioPrev", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --prv"), { locked = true, description = "previous track" })
hl.bind("xf86audiostop", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --stop"), { locked = true, description = "stop" })

-- Screenshot keybindings NOTE: You may need to press Fn key as well
hl.bind("SUPER + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"), { description = "screenshot now" })
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"), { description = "screenshot (area)" })
hl.bind("SUPER + CTRL + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"), { description = "screenshot in 5s" })
hl.bind("SUPER + CTRL + SHIFT + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"), { description = "screenshot in 10s" })
hl.bind("ALT + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"), { description = "screenshot active window" })

-- screenshot with swappy (another screenshot tool)
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --swappy"), { description = "screenshot (swappy)" })

-- Resize windows
hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true, description = "resize left (-50)" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true, description = "resize right (+50)" })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true, description = "resize up (-50)" })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true, description = "resize down (+50)" })

-- Move windows
hl.bind("SUPER + CTRL + left", hl.dsp.window.move({ direction = "left" }), { description = "move window left" })
hl.bind("SUPER + CTRL + right", hl.dsp.window.move({ direction = "right" }), { description = "move window right" })
hl.bind("SUPER + CTRL + up", hl.dsp.window.move({ direction = "up" }), { description = "move window up" })
hl.bind("SUPER + CTRL + down", hl.dsp.window.move({ direction = "down" }), { description = "move window down" })

-- Swap windows
hl.bind("SUPER + ALT + left", hl.dsp.window.swap({ direction = "left" }), { description = "swap window left" })
hl.bind("SUPER + ALT + right", hl.dsp.window.swap({ direction = "right" }), { description = "swap window right" })
hl.bind("SUPER + ALT + up", hl.dsp.window.swap({ direction = "up" }), { description = "swap window up" })
hl.bind("SUPER + ALT + down", hl.dsp.window.swap({ direction = "down" }), { description = "swap window down" })

-- group
hl.bind("SUPER + G", hl.dsp.group.toggle(), { description = "toggle group" })

-- Navigate within a group
hl.bind("SUPER + Tab", hl.dsp.group.next(), { description = "Change Group Forward" })
hl.bind("SUPER + CTRL + tab", hl.dsp.group.next(), { description = "change active in group" })
hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev(), { description = "Change Group Back" })

-- Move window into/out of group
hl.bind("SUPER + CTRL + K", hl.dsp.window.move({ into_group = "left" }), { description = "Move left into group" })  -- Move active window left into a group A
hl.bind("SUPER + CTRL + L", hl.dsp.window.move({ into_group = "right" }), { description = "Move Right into group" })  -- Move active window right into a group
hl.bind("SUPER + CTRL + H", hl.dsp.window.move({ out_of_group = true }), { description = "Move active out of group" })  -- Move active window out of group

-- Try to dynamically move in grouped window and when ungrouped
--  Not working for me DW 11/26/25  PR: https://github.com/JaKooLit/Hyprland-Dots/pull/872
--bindd = $mainMod, right, focus right, exec, bash -c 'if hyprctl activewindow -j | jq -e "((.grouped | type) == \"boolean\") or (.address == (.grouped[-1] // empty))" >/dev/null 2>&1; then hyprctl dispatch movefocus r; else hyprctl dispatch changegroupactive f; fi'
--bindd = $mainMod, left, focus left, exec, bash -c 'if hyprctl activewindow -j | jq -e "((.grouped | type) == \"boolean\") or (.address == (.grouped[0] // empty))" >/dev/null 2>&1; then hyprctl dispatch movefocus l; else hyprctl dispatch changegroupactive b; fi'

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }), { description = "focus left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }), { description = "focus right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }), { description = "focus up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }), { description = "focus down" })

-- Workspaces related
hl.bind("SUPER + tab", hl.dsp.focus({ workspace = "m+1" }), { description = "next workspace" })
hl.bind("SUPER + SHIFT + tab", hl.dsp.focus({ workspace = "m-1" }), { description = "previous workspace" })

-- Special workspace
hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "special" }), { description = "move to special workspace" })
hl.bind("SUPER + U", hl.dsp.workspace.toggle_special("special"), { description = "toggle special workspace" })

-- The following mappings use the key codes to better support various keyboard layouts
-- 1 is code:10, 2 is code 11, etc
-- Switch workspaces with mainMod + [0-9]
hl.bind("SUPER + code:10", hl.dsp.focus({ workspace = "1" }), { description = "workspace 1" })  -- NOTE: code:10 = key 1
hl.bind("SUPER + code:11", hl.dsp.focus({ workspace = "2" }), { description = "workspace 2" })  -- NOTE: code:11 = key 2
hl.bind("SUPER + code:12", hl.dsp.focus({ workspace = "3" }), { description = "workspace 3" })  -- NOTE: code:12 = key 3
hl.bind("SUPER + code:13", hl.dsp.focus({ workspace = "4" }), { description = "workspace 4" })  -- NOTE: code:13 = key 4
hl.bind("SUPER + code:14", hl.dsp.focus({ workspace = "5" }), { description = "workspace 5" })  -- NOTE: code:14 = key 5
hl.bind("SUPER + code:15", hl.dsp.focus({ workspace = "6" }), { description = "workspace 6" })  -- NOTE: code:15 = key 6
hl.bind("SUPER + code:16", hl.dsp.focus({ workspace = "7" }), { description = "workspace 7" })  -- NOTE: code:16 = key 7
hl.bind("SUPER + code:17", hl.dsp.focus({ workspace = "8" }), { description = "workspace 8" })  -- NOTE: code:17 = key 8
hl.bind("SUPER + code:18", hl.dsp.focus({ workspace = "9" }), { description = "workspace 9" })  -- NOTE: code:18 = key 9
hl.bind("SUPER + code:19", hl.dsp.focus({ workspace = "10" }), { description = "workspace 10" })  -- NOTE: code:19 = key 0

-- Move active window and follow to workspace mainMod + SHIFT [0-9]
hl.bind("SUPER + SHIFT + code:10", hl.dsp.window.move({ workspace = "1" }), { description = "move to workspace 1" })  -- NOTE: code:10 = key 1
hl.bind("SUPER + SHIFT + code:11", hl.dsp.window.move({ workspace = "2" }), { description = "move to workspace 2" })  -- NOTE: code:11 = key 2
hl.bind("SUPER + SHIFT + code:12", hl.dsp.window.move({ workspace = "3" }), { description = "move to workspace 3" })  -- NOTE: code:12 = key 3
hl.bind("SUPER + SHIFT + code:13", hl.dsp.window.move({ workspace = "4" }), { description = "move to workspace 4" })  -- NOTE: code:13 = key 4
hl.bind("SUPER + SHIFT + code:14", hl.dsp.window.move({ workspace = "5" }), { description = "move to workspace 5" })  -- NOTE: code:14 = key 5
hl.bind("SUPER + SHIFT + code:15", hl.dsp.window.move({ workspace = "6" }), { description = "move to workspace 6" })  -- NOTE: code:15 = key 6
hl.bind("SUPER + SHIFT + code:16", hl.dsp.window.move({ workspace = "7" }), { description = "move to workspace 7" })  -- NOTE: code:16 = key 7
hl.bind("SUPER + SHIFT + code:17", hl.dsp.window.move({ workspace = "8" }), { description = "move to workspace 8" })  -- NOTE: code:17 = key 8
hl.bind("SUPER + SHIFT + code:18", hl.dsp.window.move({ workspace = "9" }), { description = "move to workspace 9" })  -- NOTE: code:18 = key 9
hl.bind("SUPER + SHIFT + code:19", hl.dsp.window.move({ workspace = "10" }), { description = "move to workspace 10" })  -- NOTE: code:19 = key 0
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "-1" }), { description = "move to previous workspace" })  -- brackets [
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1" }), { description = "move to next workspace" })  -- brackets ]

-- Move active window to a workspace silently mainMod + CTRL [0-9]
hl.bind("SUPER + CTRL + code:10", hl.dsp.window.move({ workspace = "1", follow = false }), { description = "move silently to workspace 1" })  -- NOTE: code:10 = key 1
hl.bind("SUPER + CTRL + code:11", hl.dsp.window.move({ workspace = "2", follow = false }), { description = "move silently to workspace 2" })  -- NOTE: code:11 = key 2
hl.bind("SUPER + CTRL + code:12", hl.dsp.window.move({ workspace = "3", follow = false }), { description = "move silently to workspace 3" })  -- NOTE: code:12 = key 3
hl.bind("SUPER + CTRL + code:13", hl.dsp.window.move({ workspace = "4", follow = false }), { description = "move silently to workspace 4" })  -- NOTE: code:13 = key 4
hl.bind("SUPER + CTRL + code:14", hl.dsp.window.move({ workspace = "5", follow = false }), { description = "move silently to workspace 5" })  -- NOTE: code:14 = key 5
hl.bind("SUPER + CTRL + code:15", hl.dsp.window.move({ workspace = "6", follow = false }), { description = "move silently to workspace 6" })  -- NOTE: code:15 = key 6
hl.bind("SUPER + CTRL + code:16", hl.dsp.window.move({ workspace = "7", follow = false }), { description = "move silently to workspace 7" })  -- NOTE: code:16 = key 7
hl.bind("SUPER + CTRL + code:17", hl.dsp.window.move({ workspace = "8", follow = false }), { description = "move silently to workspace 8" })  -- NOTE: code:17 = key 8
hl.bind("SUPER + CTRL + code:18", hl.dsp.window.move({ workspace = "9", follow = false }), { description = "move silently to workspace 9" })  -- NOTE: code:18 = key 9
hl.bind("SUPER + CTRL + code:19", hl.dsp.window.move({ workspace = "10", follow = false }), { description = "move silently to workspace 10" })  -- NOTE: code:19 = key 0
hl.bind("SUPER + CTRL + bracketleft", hl.dsp.window.move({ workspace = "-1", follow = false }), { description = "move silently to previous workspace" })  -- brackets [
hl.bind("SUPER + CTRL + bracketright", hl.dsp.window.move({ workspace = "+1", follow = false }), { description = "move silently to next workspace" })  -- brackets ]

-- Scroll through existing workspaces with mainMod + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "next workspace" })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "previous workspace" })
hl.bind("SUPER + period", hl.dsp.focus({ workspace = "e+1" }), { description = "next workspace" })
hl.bind("SUPER + comma", hl.dsp.focus({ workspace = "e-1" }), { description = "previous workspace" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "move window" })  -- NOTE: mouse:272 = left click
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "resize window" })  -- NOTE: mouse:272 = right click

-- /* ---- Relian-Hyprland ---- */
-- Mostly for laptops. Addendum to Keybinds.lua
local scriptsDir = require("UserConfigs.01-UserDefaults").scriptsDir

-- for disabling Touchpad. hyprctl devices to get device name.
local Touchpad_Device = "asue1209:00-04f3:319f-touchpad"
local TOUCHPAD_ENABLED = true
-- /* ---- Relian-Hyprland ---- */  #
-- See https://wiki.hyprland.org/Configuring/Keywords/ for more variable settings
-- These configs are mostly for laptops. This is addemdum to Keybinds.conf



hl.bind("xf86KbdBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --dec"), { repeating = true })  -- decrease keyboard brightness
hl.bind("xf86KbdBrightnessUp", hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --inc"), { repeating = true })  -- increase keyboard brightness
hl.bind("xf86Launch1", hl.dsp.exec_cmd("rog-control-center"))  -- ASUS Armory crate button
hl.bind("xf86Launch3", hl.dsp.exec_cmd("asusctl led-mode -n"))  -- FN+F4 Switch keyboard RGB profile
hl.bind("xf86Launch4", hl.dsp.exec_cmd("asusctl profile -n"))  -- FN+F5 change of fan profiles (Quite, Balance, Performance)
hl.bind("xf86MonBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --dec"), { repeating = true })  -- decrease monitor brightness
hl.bind("xf86MonBrightnessUp", hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --inc"), { repeating = true })  -- increase monitor brightness
hl.bind("xf86TouchpadToggle", hl.dsp.exec_cmd(scriptsDir .. "/TouchPad.sh"))  -- disable touchpad

-- Screenshot keybindings using F6 (no PrinSrc button)
hl.bind("SUPER + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"))  -- screenshot
hl.bind("SUPER + SHIFT + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"))  -- screenshot (area)
hl.bind("SUPER + CTRL + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"))  -- # screenshot (5 secs delay)
hl.bind("SUPER + ALT + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"))  -- screenshot (10 secs delay)
hl.bind("ALT + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"))  -- screenshot (active window only)

hl.device({ name = Touchpad_Device, enabled = TOUCHPAD_ENABLED })

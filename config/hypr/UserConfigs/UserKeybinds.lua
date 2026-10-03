-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- This is where you put your own keybinds. Check configs/Keybinds.lua first to avoid conflicts.
-- Wiki: https://wiki.hypr.land/Configuring/Basics/Binds/
-- See also configs/Laptops.lua for laptop keybinds

local D = require("UserConfigs.01-UserDefaults")
local scriptsDir, UserScripts, term, files = D.scriptsDir, D.UserScripts, D.term, D.files

-- To REMAP an existing keybind, hl.unbind() it first. Keys are CASE SENSITIVE and must match the original bind.
-- E.g.
-- hl.unbind("SUPER + Return")
-- hl.bind("SUPER + Return", hl.dsp.exec_cmd("ghostty"), { description = "Open terminal" })
--
-- If you are ADDING a bind, include a description so the keybind search menu shows it properly.
-- hl.bind("SUPER + Z", hl.dsp.exec_cmd("APPNAME"), { description = "My z app" })

-- Grow / shrink the active window with SUPER + = and SUPER + -
hl.bind("SUPER + equal", hl.dsp.window.resize({ x = 50, y = 50, relative = true }), { repeating = true, description = "grow window" })
hl.bind("SUPER + minus", hl.dsp.window.resize({ x = -50, y = -50, relative = true }), { repeating = true, description = "shrink window" })

-- For passthrough keyboard into a VM
-- hl.bind("SUPER + ALT + P", hl.dsp.submap("passthru"))
-- hl.define_submap("passthru", "SUPER + ALT + P", function() end)

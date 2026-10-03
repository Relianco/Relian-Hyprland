-- /* ---- Relian-Hyprland ---- */
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

-- Window resize, same layout as Omarchy: the - and = keys (code:20 / code:21).
--   plain = 100px, + ALT = a little (25px), + CTRL = a lot (300px), + SHIFT = vertical instead of horizontal
local function resize_binds(mods, step, label)
    local pre = mods ~= "" and (mods .. " + ") or ""
    hl.bind("SUPER + " .. pre .. "code:20", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true, description = "resize narrower" .. label })
    hl.bind("SUPER + " .. pre .. "code:21", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true, description = "resize wider" .. label })
    hl.bind("SUPER + SHIFT + " .. pre .. "code:20", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true, description = "resize shorter" .. label })
    hl.bind("SUPER + SHIFT + " .. pre .. "code:21", hl.dsp.window.resize({ x = 0, y = step, relative = true }), { repeating = true, description = "resize taller" .. label })
end
resize_binds("", 100, "")
resize_binds("ALT", 25, " (a little)")
resize_binds("CTRL", 300, " (a lot)")

-- For passthrough keyboard into a VM
-- hl.bind("SUPER + ALT + P", hl.dsp.submap("passthru"))
-- hl.define_submap("passthru", "SUPER + ALT + P", function() end)

-- /* ---- Relian-Hyprland ---- */
-- Decoration settings. https://wiki.hypr.land/Configuring/Variables/#decoration
-- Colors come from wallust (wallust/wallust-hyprland.lua)
local c = require("wallust.wallust-hyprland")
-- translucent version of an "rgb(RRGGBB)" color; keeps inactive borders subtle on any theme
local function alpha(col, a) return (col:gsub("^rgb%((%x+)%)$", "rgba(%1" .. a .. ")")) end

hl.config({
    general = {
        border_size = 2,
        gaps_in = 5,
        gaps_out = 10,  -- Omarchy spacing (was 2 / 4)
        col = {
            active_border = c.color12,
            inactive_border = alpha(c.color8, "66"),
        },
    },

    decoration = {
        rounding = 0, -- square corners
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        fullscreen_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.1,
        dim_special = 0.8,

        -- flat borders: no shadow (the accent-colored shadow read as a glow around the focused window)
        shadow = { enabled = false },

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            ignore_opacity = true,
            new_optimizations = true,
            special = true,
            popups = true,
        },
    },

    group = {
        col = { border_active = c.color15 },
        groupbar = { col = { active = c.color0 } },
    },
})

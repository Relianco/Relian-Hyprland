-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
-- Decoration settings. https://wiki.hypr.land/Configuring/Variables/#decoration
-- Colors come from wallust (wallust/wallust-hyprland.lua)
local c = require("wallust.wallust-hyprland")

hl.config({
    general = {
        border_size = 2,
        gaps_in = 2,
        gaps_out = 4,
        col = {
            active_border = c.color12,
            inactive_border = c.color10,
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

        shadow = {
            enabled = true,
            range = 3,
            render_power = 1,
            color = c.color12,
            color_inactive = c.color10,
        },

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

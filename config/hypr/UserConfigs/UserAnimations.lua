-- /* ---- Relian-Hyprland ---- */
-- https://wiki.hypr.land/Configuring/Animations/
hl.config({ animations = { enabled = true } })

local function bezier(name, x0, y0, x1, y1)
    hl.curve(name, { type = "bezier", points = { { x0, y0 }, { x1, y1 } } })
end
bezier("wind",      0.05, 0.9,  0.1,  1.05)
bezier("winIn",     0.1,  1.1,  0.1,  1.1)
bezier("winOut",    0.3,  -0.3, 0,    1)
bezier("liner",     1,    1,    1,    1)
bezier("overshot",  0.05, 0.9,  0.1,  1.05)
bezier("smoothOut", 0.5,  0,    0.99, 0.99)
bezier("smoothIn",  0.5,  -0.5, 0.68, 1.5)

hl.animation({ leaf = "windows",       enabled = true, speed = 6,   bezier = "wind",      style = "slide" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 5,   bezier = "winIn",     style = "slide" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,   bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 5,   bezier = "wind",      style = "slide" })
hl.animation({ leaf = "border",        enabled = true, speed = 1,   bezier = "liner" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,   bezier = "smoothOut" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5,   bezier = "overshot" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5,   bezier = "winIn",     style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5,   bezier = "winOut",    style = "slide" })

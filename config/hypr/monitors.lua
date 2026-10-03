-- /* ---- Relian-Hyprland ---- */
-- Default monitor config. https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Use `hyprctl monitors` to get the info. A copy of the original defaults lives in Monitor_Profiles/.
-- NOTE: nwg-displays writes monitors.conf / workspaces.conf (hyprlang); it does not generate Lua, so edit here.

-- Highest refresh rate on every monitor (the old default ended up here too: 5120x1440@240 on the ultrawide).
-- "preferred" alone would pick the monitor's default mode, often 60Hz.
hl.monitor({ output = "", mode = "highrr", position = "auto", scale = 1 })
-- Default mode:         hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
-- High Resolution:      hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1 })

-- Examples
-- hl.monitor({ output = "eDP-1", mode = "2560x1440@165", position = "0x0", scale = 1 })
-- hl.monitor({ output = "DP-3",  mode = "1920x1080@240", position = "auto", scale = 1 })
-- hl.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "auto", scale = 1 }) -- QEMU-KVM, virtualbox, vmware
-- hl.monitor({ output = "name", disabled = true })                                          -- disable a monitor
-- hl.monitor({ output = "DP-3", mode = "1920x1080@60", position = "0x0", scale = 1, mirror = "DP-2" }) -- mirror
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, bitdepth = 10 })          -- 10 bit

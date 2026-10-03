-- /* ---- Relian-Hyprland ---- */
-- Gaming settings (ported from the old 99-custom.conf): VRR + fullscreen/flicker fixes for Proton, gamescope and Wine/WoW.

hl.config({
    misc = {
        -- 0=off 1=on 2=fullscreen 3=fullscreen + game-content only. Videos report content=video so they don't flip VRR -> no flicker
        vrr = 3,
    },
})

-- vrr=3 only triggers for windows whose content-type is "game".
-- Wayland-native games + gamescope report this themselves; XWayland Proton games can't,
-- so tag them by class. `hyprctl activewindow | grep class` on a game to find its class.
-- Proton/Steam games:
hl.window_rule({ name = "vrr-content-steam", match = { class = [[^(steam_app_\d+)$]] }, content = "game" })

-- gamescope sessions:
hl.window_rule({ name = "vrr-content-gamescope", match = { class = "^(gamescope)$" }, content = "game" })

-- Lutris/wine (Battle.net -> WoW). Wine windows get tiled by default, so WoW's fullscreen request and the tiled
-- rect (monitor minus the waybar reserve) fight each other and the window flickers between the two sizes.
-- Float + real fullscreen ends the argument. Pair with WoW's "Windowed (Fullscreen)" mode.
hl.window_rule({
    name = "wine-games",
    -- umu/Proton launches report class steam_app_default, so gate that one by title.
    match = { class = [[^(wow\.exe|wowclassic\.exe|steam_app_default)$]], title = "^(World of Warcraft)$" },
    content = "game",
    float = true,
    no_blur = true,
    -- Force internal fullscreen AND report fullscreen back to the client, so wine stops re-asking. Plain
    -- `fullscreen` fights the client's own requests: each XWayland request toggles the state, which is the flicker.
    -- values: -1 current, 0 none, 1 maximize, 2 fullscreen. internal client.
    fullscreen_state = "2 2",
    -- `configure` (new in 0.56) drops X11 configure requests too: the resize half of the jitter, not just the
    -- fullscreen-state half.
    suppress_event = "fullscreen maximize configure",
})

-- The launcher itself just wants to float, not go fullscreen.
hl.window_rule({ name = "wine-battlenet", match = { class = [[^(battle\.net\.exe|explorer\.exe)$]] }, float = true })

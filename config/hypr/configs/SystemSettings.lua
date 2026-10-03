-- /* ---- Relian-Hyprland ---- */
-- Default settings (Lua). Refer to https://wiki.hypr.land/Configuring/Variables/
-- NOTE: some settings are in UserConfigs/UserDecorations.lua and UserAnimations.lua
local scriptsDir = require("UserConfigs.01-UserDefaults").scriptsDir

-- cursor zoom, same behaviour as the old hyprctl getoption/awk pipeline
local function zoom(m)
    return function()
        local f = tonumber(hl.get_config("cursor.zoom_factor")) or 1
        if f < 1 then f = 1 end
        hl.config({ cursor = { zoom_factor = math.max(1, f * m) } })
    end
end

hl.config({
    dwindle = {
        preserve_split = true,
        -- smart_split = true,
        special_scale_factor = 0.8,
    },

    master = {
        new_status = "master",
        new_on_top = 1,
        mfact = 0.5,
    },

    -- A lone window on a workspace is centred at this aspect ratio instead of stretching across the whole monitor.
    -- On a 5120x1440 ultrawide, 16:9 gives a 2560x1440 window in the middle. Opening a second window tiles normally.
    -- Use { 21, 9 } for wider, or remove this block to fill the screen.
    layout = { single_window_aspect_ratio = { 16, 9 } },

    general = {
        resize_on_border = true,
        layout = "dwindle",
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        repeat_rate = 50,
        repeat_delay = 300,
        sensitivity = 0, -- mouse sensitivity
        -- accel_profile = "", -- flat or adaptive or blank or EMPTY means libinput's default mode
        numlock_by_default = true,
        left_handed = false,
        follow_mouse = 1,
        float_switch_override_focus = false,

        touchpad = {
            disable_while_typing = true,
            natural_scroll = true,
            clickfinger_behavior = false,
            middle_button_emulation = false,
            tap_to_click = true,
            drag_lock = false,
        },

        -- for devices with touchdevice ie. touchscreen
        touchdevice = { enabled = true },
        tablet = { transform = 0, left_handed = false },
    },

    gestures = {
        workspace_swipe_distance = 500,
        workspace_swipe_invert = true,
        workspace_swipe_min_speed_to_force = 30,
        workspace_swipe_cancel_ratio = 0.5,
        workspace_swipe_create_new = true,
        workspace_swipe_forever = true,
        -- workspace_swipe_use_r = true, -- uncomment if wanted a forever create a new workspace with swipe right
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 2,
        mouse_move_enables_dpms = true,
        enable_swallow = false,
        swallow_regex = "^(kitty)$",
        focus_on_activate = false,
        initial_workspace_tracking = 0,
        middle_click_paste = false,
        enable_anr_dialog = true, -- Application not Responding (ANR)
        anr_missed_pings = 15,    -- ANR Threshold default 1 is too low
        allow_session_lock_restore = true, -- Prevent lockscreen crash when resume from suspend
    },

    -- opengl = { nvidia_anti_flicker = true },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },

    -- Could help when scaling and not pixelating
    xwayland = {
        enabled = true,
        force_zero_scaling = true,
    },

    render = { direct_scanout = 0 },

    cursor = {
        sync_gsettings_theme = true,
        no_hardware_cursors = 2, -- change to 1 if want to disable
        enable_hyprcursor = true,
        warp_on_change_workspace = 2,
        no_warps = true,
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up",   action = zoom(1.5) })
hl.gesture({ fingers = 4, direction = "down", action = zoom(1 / 1.5) })
hl.gesture({ fingers = 3, direction = "up",   action = function()
    hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/OverviewToggle.sh"))
end })

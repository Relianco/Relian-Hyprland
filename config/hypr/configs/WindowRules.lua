-- /* ---- Relian-Hyprland ---- */
-- Window and layer rules (vendor defaults).
-- NOTE: floating-window widths use monitor_h*(pct*16/9) rather than monitor_w*pct so ultrawide (32:9) monitors
-- get the same window width a 16:9 screen would, instead of 70% of 5120px. https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- /* ---- Relian-Hyprland ---- */  #
-- Vendor defaults for window rules and layerrules
-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

-- NOTES: This is only for Hyprland > 0.48

-- note for ja: This should NOT be implemented on Debian and Ubuntu

-- windowrule - tags - add apps under appropriate tag to use the same settings
-- browser tags
hl.window_rule({ match = { class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$" }, tag = "+browser" })
hl.window_rule({ match = { class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$" }, tag = "+browser" })
hl.window_rule({ match = { class = "^(chrome-.+-Default)$" }, tag = "+browser" })  -- Chrome PWAs
hl.window_rule({ match = { class = "^([Cc]hromium)$" }, tag = "+browser" })
hl.window_rule({ match = { class = "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$" }, tag = "+browser" })
hl.window_rule({ match = { class = "^(Brave-browser(-beta|-dev|-unstable)?)$" }, tag = "+browser" })
hl.window_rule({ match = { class = "^([Tt]horium-browser|[Cc]achy-browser)$" }, tag = "+browser" })
hl.window_rule({ match = { class = "^(zen-alpha|zen)$" }, tag = "+browser" })

-- notif tags
hl.window_rule({ match = { class = "^(swaync-control-center|swaync-notification-window|swaync-client|class)$" }, tag = "+notif" })

-- Relian settings tag
hl.window_rule({ match = { title = "^(Relian Quick Cheat Sheet)$" }, tag = "+Relian_Cheat" })
hl.window_rule({ match = { title = "^(Relian Hyprland Settings)$" }, tag = "+Relian_Settings" })
hl.window_rule({ match = { class = "^(nwg-displays|nwg-look)$" }, tag = "+Relian-Settings" })

-- terminal tags
hl.window_rule({ match = { class = "^(Alacritty|kitty|kitty-dropterm)$" }, tag = "+terminal" })

-- email tags
hl.window_rule({ match = { class = "^([Tt]hunderbird|org.gnome.Evolution)$" }, tag = "+email" })
hl.window_rule({ match = { class = "^(eu.betterbird.Betterbird)$" }, tag = "+email" })

-- project tags
hl.window_rule({ match = { class = "^(codium|codium-url-handler|VSCodium)$" }, tag = "+projects" })
hl.window_rule({ match = { class = "^(VSCode|code|code-url-handler)$" }, tag = "+projects" })
hl.window_rule({ match = { class = "^(jetbrains-.+)$" }, tag = "+projects" })  -- JetBrains IDEs

-- screenshare tags
hl.window_rule({ match = { class = "^(com.obsproject.Studio)$" }, tag = "+screenshare" })

-- IM tags
hl.window_rule({ match = { class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$" }, tag = "+im" })
hl.window_rule({ match = { class = "^([Ff]erdium)$" }, tag = "+im" })
hl.window_rule({ match = { class = "^([Ww]hatsapp-for-linux)$" }, tag = "+im" })
hl.window_rule({ match = { class = "^(ZapZap|com.rtosta.zapzap)$" }, tag = "+im" })
hl.window_rule({ match = { class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$" }, tag = "+im" })
hl.window_rule({ match = { class = "^(teams-for-linux)$" }, tag = "+im" })
hl.window_rule({ match = { class = "^(im.riot.Riot|Element)$" }, tag = "+im" })  -- Element Matrix client

-- game tags
hl.window_rule({ match = { class = "^(gamescope)$" }, tag = "+games" })
hl.window_rule({ match = { class = "^(steam_app_\\d+)$" }, tag = "+games" })

-- gamestore tags
hl.window_rule({ match = { class = "^([Ss]team)$" }, tag = "+gamestore" })
hl.window_rule({ match = { title = "^([Ll]utris)$" }, tag = "+gamestore" })
hl.window_rule({ match = { class = "^(com.heroicgameslauncher.hgl)$" }, tag = "+gamestore" })

-- file-manager tags
hl.window_rule({ match = { class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$" }, tag = "+file-manager" })
hl.window_rule({ match = { class = "^(app.drey.Warp)$" }, tag = "+file-manager" })

-- wallpaper tags
hl.window_rule({ match = { class = "^([Ww]aytrogen)$" }, tag = "+wallpaper" })

-- multimedia tags
hl.window_rule({ match = { class = "^([Aa]udacious)$" }, tag = "+multimedia" })

-- multimedia-video tags
hl.window_rule({ match = { class = "^([Mm]pv|vlc)$" }, tag = "+multimedia_video" })

-- settings tags
hl.window_rule({ match = { title = "^(ROG Control)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(wihotspot(-gui)?)$" }, tag = "+settings" })  -- wifi hotspot
hl.window_rule({ match = { class = "^([Bb]aobab|org.gnome.[Bb]aobab)$" }, tag = "+settings" })  -- Disk usage analyzer
hl.window_rule({ match = { class = "^(gnome-disks|wihotspot(-gui)?)$" }, tag = "+settings" })
hl.window_rule({ match = { title = "(Kvantum Manager)" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(file-roller|org.gnome.FileRoller)$" }, tag = "+settings" })  -- archive manager
hl.window_rule({ match = { class = "^(nm-applet|nm-connection-editor|blueman-manager)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(qt5ct|qt6ct|[Yy]ad)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "(xdg-desktop-portal-gtk)" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^([Rr]ofi)$" }, tag = "+settings" })

-- viewer tags
hl.window_rule({ match = { class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$" }, tag = "+viewer" })  -- system monitor
hl.window_rule({ match = { class = "^(evince)$" }, tag = "+viewer" })  -- document viewer
hl.window_rule({ match = { class = "^(eog|org.gnome.Loupe)$" }, tag = "+viewer" })  -- image viewer

-- Some special override rules
hl.window_rule({ match = { tag = "multimedia_video*" }, no_blur = true })
hl.window_rule({ match = { tag = "multimedia_video*" }, opacity = "1.0" })

-- POSITION
-- windowrule = center,floating:1 # warning, it cause even the menu to float and center.
hl.window_rule({ match = { tag = "Relian_Cheat*" }, center = true })
hl.window_rule({ match = { class = "([Tt]hunar)", title = "negative:(.*[Tt]hunar.*)" }, center = true })
hl.window_rule({ match = { title = "^(ROG Control)$" }, center = true })
hl.window_rule({ match = { tag = "Relian-Settings*" }, center = true })
hl.window_rule({ match = { title = "^(Keybindings)$" }, center = true })
hl.window_rule({ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, center = true })
hl.window_rule({ match = { class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, center = true })
hl.window_rule({ match = { class = "^([Ff]erdium)$" }, center = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, move = { "monitor_w*0.72", "monitor_h*0.07" } })
--windowrule = move 72% 7%,title:^(Firefox)$

-- windowrule to avoid idle for fullscreen apps
--windowrule = idleinhibit fullscreen, class:^(*)$
--windowrule = idleinhibit fullscreen, title:^(*)$
hl.window_rule({ match = { fullscreen = true }, idle_inhibit = "fullscreen" })

-- windowrule move to workspace
--windowrule = workspace 1, tag:email*
--windowrule = workspace 2, tag:browser*
--windowrule = workspace 3, class:^([Tt]hunar)$
--windowrule = workspace 3, tag:projects*
--windowrule = workspace 5, tag:gamestore*
--windowrule = workspace 7, tag:im*
--windowrule = workspace 8, tag:games*

-- windowrule move to workspace (silent)
--windowrule = workspace 4 silent, tag:screenshare*
--windowrule = workspace 6 silent, class:^(virt-manager)$
--windowrule = workspace 6 silent, class:^(.virt-manager-wrapped)$
--windowrule = workspace 9 silent, tag:multimedia*
--
-- FLOAT
hl.window_rule({ match = { tag = "Relian_Cheat*" }, float = true })
hl.window_rule({ match = { tag = "wallpaper*" }, float = true })
hl.window_rule({ match = { tag = "settings*" }, float = true })
hl.window_rule({ match = { tag = "viewer*" }, float = true })
hl.window_rule({ match = { tag = "Relian-Settings*" }, float = true })
hl.window_rule({ match = { class = "([Zz]oom|onedriver|onedriver-launcher)$" }, float = true })
hl.window_rule({ match = { class = "(org.gnome.Calculator)", title = "(Calculator)" }, float = true })
hl.window_rule({ match = { class = "^(mpv|com.github.rafostar.Clapper)$" }, float = true })
hl.window_rule({ match = { class = "^([Qq]alculate-gtk)$" }, float = true })
--windowrule = float, class:^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$
hl.window_rule({ match = { class = "^([Ff]erdium)$" }, float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })
--windowrule = float, title:^(Firefox)$

-- windowrule - ######### float popups and dialogue #######
hl.window_rule({ match = { title = "^(Authentication Required)$" }, float = true })
hl.window_rule({ match = { title = "^(Authentication Required)$" }, center = true })
hl.window_rule({ match = { class = "(codium|codium-url-handler|VSCodium)", title = "negative:(.*codium.*|.*VSCodium.*)" }, float = true })
hl.window_rule({ match = { class = "^(com.heroicgameslauncher.hgl)$", title = "negative:(Heroic Games Launcher)" }, float = true })
hl.window_rule({ match = { class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, float = true })
hl.window_rule({ match = { class = "([Tt]hunar)", title = "negative:(.*[Tt]hunar.*)" }, float = true })

hl.window_rule({ match = { title = "^(Add Folder to Workspace)$" }, float = true })
hl.window_rule({ match = { title = "^(Add Folder to Workspace)$" }, size = { "monitor_h*1.244", "monitor_h*0.6" } })
hl.window_rule({ match = { title = "^(Add Folder to Workspace)$" }, center = true })

hl.window_rule({ match = { title = "^(Save As)$" }, float = true })
hl.window_rule({ match = { title = "^(Save As)$" }, size = { "monitor_h*1.244", "monitor_h*0.6" } })
hl.window_rule({ match = { title = "^(Save As)$" }, center = true })

hl.window_rule({ match = { initial_title = "(Open Files)" }, float = true })
hl.window_rule({ match = { initial_title = "(Open Files)" }, size = { "monitor_h*1.244", "monitor_h*0.6" } })

hl.window_rule({ match = { title = "^(SDDM Background)$" }, float = true })  -- Relian's Dots YAD for setting SDDM background
hl.window_rule({ match = { title = "^(SDDM Background)$" }, center = true })  -- Relian's Dots YAD for setting SDDM background
hl.window_rule({ match = { title = "^(SDDM Background)$" }, size = { "monitor_h*0.284", "monitor_h*0.12" } })  -- Relian's Dots YAD for setting SDDM background
-- END of float popups and dialogue #######

-- OPACITY
hl.window_rule({ match = { tag = "browser*" }, opacity = "0.99 0.8" })
hl.window_rule({ match = { tag = "projects*" }, opacity = "0.9 0.8" })
hl.window_rule({ match = { tag = "im*" }, opacity = "0.94 0.86" })
hl.window_rule({ match = { tag = "multimedia*" }, opacity = "0.94 0.86" })
hl.window_rule({ match = { tag = "file-manager*" }, opacity = "1.0 override 1.0 override" })  -- solid: readable, like Omarchy
hl.window_rule({ match = { tag = "terminal*" }, opacity = "0.9 0.7" })
hl.window_rule({ match = { tag = "settings*" }, opacity = "0.8 0.7" })
hl.window_rule({ match = { tag = "viewer*" }, opacity = "0.82 0.75" })
hl.window_rule({ match = { tag = "wallpaper*" }, opacity = "0.9 0.7" })
hl.window_rule({ match = { class = "^(gedit|org.gnome.TextEditor|mousepad)$" }, opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(deluge)$" }, opacity = "0.9 0.8" })
hl.window_rule({ match = { class = "^(seahorse)$" }, opacity = "0.9 0.8" })  -- gnome-keyring gui
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, opacity = "0.95 0.75" })

-- SIZE
-- AI agent terminals opened by AgentPrompt.sh / the waybar agents icon
hl.window_rule({ match = { class = "^(agent)$" }, float = true })
hl.window_rule({ match = { class = "^(agent)$" }, center = true })
hl.window_rule({ match = { class = "^(agent)$" }, size = { "monitor_h*1.6", "monitor_h*0.75" } })
hl.window_rule({ match = { tag = "Relian_Cheat*" }, size = { "monitor_h*1.156", "monitor_h*0.9" } })
hl.window_rule({ match = { tag = "wallpaper*" }, size = { "monitor_h*1.244", "monitor_h*0.7" } })
hl.window_rule({ match = { tag = "settings*" }, size = { "monitor_h*1.244", "monitor_h*0.7" } })
hl.window_rule({ match = { class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, size = { "monitor_h*1.067", "monitor_h*0.7" } })
hl.window_rule({ match = { class = "^([Ff]erdium)$" }, size = { "monitor_h*1.067", "monitor_h*0.7" } })

--windowrule = size 25% 25%, title:^(Picture-in-Picture)$
--windowrule = size 25% 25%, title:^(Firefox)$

-- PINNING
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, pin = true })
--windowrule = pin,title:^(Firefox)$

-- windowrule - extras
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, keep_aspect_ratio = true })

-- BLUR & FULLSCREEN
hl.window_rule({ match = { tag = "games*" }, no_blur = true })
hl.window_rule({ match = { tag = "games*" }, fullscreen = true })


--This not gonna take the focus to the window that appears when hovering over some of the parts of the IntelliJ Products
hl.window_rule({ match = { class = "^(jetbrains-*)" }, no_initial_focus = true })
hl.window_rule({ match = { title = "^(wind.*)$" }, no_initial_focus = true })

--windowrule = bordercolor rgb(EE4B55) rgb(880808), fullscreen:1
--windowrule = bordercolor rgb(282737) rgb(1E1D2D), floating:1
--windowrule = opacity 0.8 0.8, pinned:1

-- LAYER RULES
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true })
hl.layer_rule({ match = { namespace = "notifications" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:overview" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell:overview" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:overview" }, ignore_alpha = 0.5 })

--layerrule = ignorealpha 0.5, tag:notif*

--layerrule = ignorezero, class:^([Rr]ofi)$
--layerrule = blur, class:^([Rr]ofi)$
--layerrule = unset,class:^([Rr]ofi)$
--layerrule = ignorezero, <rofi>

--layerrule = ignorezero, overview
--layerrule = blur, overview

-- Screensaver (scripts/Screensaver.sh): one fullscreen terminal per monitor
hl.window_rule({ match = { class = "^(org\\.relian\\.screensaver)$" }, fullscreen = true })
hl.window_rule({ match = { class = "^(org\\.relian\\.screensaver)$" }, float = true })

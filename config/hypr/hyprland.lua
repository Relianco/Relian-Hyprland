-- /* ---- Relian-Hyprland ---- */
-- Always refer to the Hyprland wiki: https://wiki.hypr.land/Configuring/Start/

-- Make `require("configs.Keybinds")` etc. resolve against ~/.config/hypr
package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. package.path

-- Initial boot script: applies initial wallpapers, theming, new settings etc.
-- Suggest not to change or delete this. As long as ~/.config/hypr/.initial_startup_done exists it will not run again.
hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/initial-boot.sh")
end)

-- Defaults first, then user additions/overrides
require("UserConfigs.01-UserDefaults")  -- default apps (also exports term/files used below)
require("configs.Keybinds")             -- pre-configured keybinds
require("configs.Startup_Apps")
require("UserConfigs.Startup_Apps")
require("configs.ENVariables")          -- environment variables (defaults)
require("UserConfigs.ENVariables")      -- environment variables (user)
require("configs.Laptops")
require("UserConfigs.Laptops")
require("configs.WindowRules")          -- window + layer rules (defaults)
require("UserConfigs.WindowRules")      -- window + layer rules (user)
require("configs.SystemSettings")       -- default hypr settings
require("UserConfigs.UserDecorations")
require("UserConfigs.UserAnimations")
require("UserConfigs.UserKeybinds")     -- put your own keybinds here
require("UserConfigs.UserSettings")     -- main user settings
require("UserConfigs.UserGaming")       -- VRR + Wine/Proton/gamescope fixes

-- monitors / workspaces (nwg-displays equivalents)
require("monitors")
require("workspaces")

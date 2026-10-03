-- /* ---- Relian-Hyprland ---- */
-- Reads 01-UserDefaults.conf (kept as plain key/value so Waybar/rofi scripts and copy.sh can still read and
-- edit it) and exposes the values to the Lua config. Edit the .conf, not this file.
local home = os.getenv("HOME")
local UserConfigs = home .. "/.config/hypr/UserConfigs"

local v = { term = "kitty", files = "thunar", Search_Engine = "https://www.google.com/search?q={}" }
local f = io.open(UserConfigs .. "/01-UserDefaults.conf")
if f then
    for raw in f:lines() do
        local line = raw:gsub("%s+#.*$", "")
        local key, val = line:match("^%$([%w_]+)%s*=%s*(.-)%s*$")
        if key and val ~= "" then v[key] = val:gsub('^"(.*)"$', "%1") end
        local editor = line:match("^env%s*=%s*EDITOR,%s*(%S+)")
        if editor then hl.env("EDITOR", editor) end
    end
    f:close()
end

return {
    home        = home,
    scriptsDir  = home .. "/.config/hypr/scripts",
    UserScripts = home .. "/.config/hypr/UserScripts",
    UserConfigs = UserConfigs,
    term        = v.term,
    files       = v.files,
    Search_Engine = v.Search_Engine,
}

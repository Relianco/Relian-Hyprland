#!/usr/bin/env bash
# Config checks for the Lua dots. Needs: Hyprland >= 0.55 (for --verify-config), bash. Run: tests/run.sh
# Nothing here touches your real ~/.config: the config is copied into a temp HOME first.
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail=0
ok()  { echo "ok   - $1"; }
bad() { echo "FAIL - $1"; [ -n "${2:-}" ] && echo "$2" | sed 's/^/       /'; fail=1; }

# verify <lua file> -> prints Hyprland's parse errors, returns 0 if "config ok"
verify() {
  local out; out=$(HOME="$tmp/home" Hyprland --verify-config -c "$1" 2>&1 | sed -n '/parsing result/,$p' | tail -n +2 | sed '/^$/d')
  [ "$out" = "config ok" ] && return 0
  echo "$out"; return 1
}

mkdir -p "$tmp/home/.config"; cp -r "$root/config/hypr" "$tmp/home/.config/hypr"

if command -v Hyprland >/dev/null; then
  out=$(verify "$tmp/home/.config/hypr/hyprland.lua") && ok "hyprland.lua passes --verify-config" || bad "hyprland.lua passes --verify-config" "$out"

  for f in "$root"/config/hypr/animations/*.lua; do
    echo "dofile([[$f]])" > "$tmp/preset.lua"
    out=$(verify "$tmp/preset.lua") && ok "animation preset $(basename "$f")" || bad "animation preset $(basename "$f")" "$out"
  done

  out=$(verify "$tmp/home/.config/hypr/Monitor_Profiles/default.lua") && ok "monitor profile default.lua" || bad "monitor profile default.lua" "$out"
else
  echo "skip - Hyprland not installed; --verify-config checks skipped"
fi

# shell syntax for every script we ship under config/hypr and the installer
for f in "$root"/config/hypr/scripts/* "$root"/config/hypr/UserScripts/*.sh "$root"/config/hypr/initial-boot.sh "$root"/install.sh; do
  case "$f" in *.sh) ;; *) head -1 "$f" 2>/dev/null | grep -q 'bash' || continue ;; esac
  [ "$(basename "$f")" = RofiEmoji.sh ] && continue # upstream: emoji data blob after `exit`, bash -n can't parse it
  out=$(bash -n "$f" 2>&1) && ok "bash -n $(basename "$f")" || bad "bash -n $(basename "$f")" "$out"
done

# regression guard: legacy hyprlang-only calls break under a Lua config
out=$(grep -rnE "hyprctl (keyword|--batch|setprop)|hyprctl dispatch [a-z_]+( |$)" "$root/config" --include=* -I 2>/dev/null \
      | grep -vE "hl\.dsp|:[0-9]+:\s*(#|--)|\.md:|RainbowBorders.bak.sh|hyprlock|README|Laptops.lua|ToggleOpaque.sh" )
[ -z "$out" ] && ok "no legacy 'hyprctl dispatch X' / keyword calls" || bad "legacy hyprctl calls found" "$out"

# every default keybind should carry a description (KeyBinds.sh cheatsheet shows it)
kb="$root/config/hypr/configs/Keybinds.lua"
nb=$(grep -c '^hl.bind(' "$kb"); nd=$(grep -c 'description = ' "$kb")
[ "$nb" -eq "$nd" ] && ok "all $nb default binds have descriptions" || bad "$nb binds but $nd descriptions in Keybinds.lua"

# wallust: the Lua and hyprlang templates must define the same colors
a=$(grep -oE '^\$[a-z0-9]+' "$root/config/wallust/templates/colors-hyprland.conf" | tr -d '$' | sort)
b=$(grep -oE '^\s+[a-z0-9]+ =' "$root/config/wallust/templates/colors-hyprland.lua" | tr -d ' =' | sort)
[ "$a" = "$b" ] && ok "wallust lua/conf templates define the same colors" || bad "wallust templates differ" "$(diff <(echo "$a") <(echo "$b"))"
grep -q "colors-hyprland.lua" "$root/config/wallust/wallust.toml" && ok "wallust.toml renders the lua template" || bad "wallust.toml missing lua template"

# 01-UserDefaults.lua parses the .conf (quotes, inline comments, underscores, EDITOR) -- needs plain lua
if command -v lua >/dev/null; then
  d="$tmp/ud"; mkdir -p "$d/.config/hypr/UserConfigs"; cp "$root/config/hypr/UserConfigs/01-UserDefaults.lua" "$d/.config/hypr/UserConfigs/"
  printf '%s\n' 'env = EDITOR,nvim #default editor' '$term = ghostty # Terminal' '$files = "nautilus"' '$Search_Engine = "https://duckduckgo.com/?q={}"' > "$d/.config/hypr/UserConfigs/01-UserDefaults.conf"
  got=$(HOME="$d" lua -e 'hl={env=function(k,v) print(k,v) end}; local u=dofile(os.getenv("HOME").."/.config/hypr/UserConfigs/01-UserDefaults.lua"); print(u.term,u.files,u.Search_Engine)' 2>&1)
  want=$(printf 'EDITOR\tnvim\nghostty\tnautilus\thttps://duckduckgo.com/?q={}')
  [ "$got" = "$want" ] && ok "01-UserDefaults.lua parses user defaults" || bad "01-UserDefaults.lua parse" "$got"
else echo "skip - lua not installed; UserDefaults parse test skipped"; fi

# run the whole config under plain lua with a permissive `hl` stub and fire hyprland.start callbacks,
# so runtime errors inside callbacks/functions (which --verify-config does not execute) show up
if command -v lua >/dev/null; then
  out=$(HOME="$tmp/home" lua -e '
    local noop = function() return setmetatable({}, getmetatable(hl)) end
    local mt; mt = { __index = function() return setmetatable({}, mt) end, __call = function() return setmetatable({}, mt) end }
    local starts = {}
    hl = setmetatable({ on = function(ev, cb) if ev == "hyprland.start" then starts[#starts+1] = cb end end,
                        get_config = function() return 1 end }, mt)
    dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.lua")
    for _, cb in ipairs(starts) do cb() end' 2>&1)
  [ -z "$out" ] && ok "config + hyprland.start callbacks run under a stubbed hl" || bad "stubbed run failed" "$out"
fi

# no key combo is bound twice across the default/user/laptop bind files (the later one would silently fight the first)
dups=$(grep -hoE '^hl\.bind\("[^"]+"' "$root/config/hypr/configs/Keybinds.lua" "$root/config/hypr/UserConfigs/UserKeybinds.lua" "$root/config/hypr/configs/Laptops.lua" | sort | uniq -d)
[ -z "$dups" ] && ok "no duplicate keybinds" || bad "duplicate keybinds" "$dups"

# flat borders: window shadows stay off (the accent-tinted shadow looked like a glow)
python3 - "$root/config/hypr/UserConfigs/UserDecorations.lua" <<'PY' && ok "window shadows are off (flat borders)" || bad "window shadows are enabled"
import re, sys
t = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"shadow\s*=\s*\{[^}]*\}", t)
sys.exit(0 if m and "enabled = false" in m.group(0) else 1)
PY

# squares and no rainbow: rounding stays 0 and the rotating-border animation stays out
grep -qE 'rounding = 0,' "$root/config/hypr/UserConfigs/UserDecorations.lua" && ok "corners are square (rounding = 0)" || bad "rounding is not 0"
grep -q 'borderangle' "$root/config/hypr/UserConfigs/UserAnimations.lua" && bad "rainbow border animation present" || ok "no rainbow border animation"

# every rofi menu theme parses (against the repo's own rofi dir, not your live one) and uses the Omarchy base, not the old layouts
if command -v rofi >/dev/null; then
  mkdir -p "$tmp/home/.config"; rm -rf "$tmp/home/.config/rofi"; cp -r "$root/config/rofi" "$tmp/home/.config/rofi"
  prob=""
  for f in "$root"/config/rofi/config-*.rasi; do
    n=$(basename "$f")
    out=$(HOME="$tmp/home" rofi -theme "$tmp/home/.config/rofi/$n" -dump-theme 2>&1)
    echo "$out" | grep -qE "WARNING|Failed to parse|Error:|error:" && prob+="$n(parse) "
    case "$n" in config-omarchy-launcher.rasi) ;; *) grep -qE '@import "~/.config/rofi/config-omarchy-(menu|launcher).rasi"' "$f" || prob+="$n(old-layout) " ;; esac
  done
  [ -z "$prob" ] && ok "all rofi menu themes parse and use the Omarchy base" || bad "rofi menu themes" "$prob"
fi

# dark-only carousel: no scheme with a light background (luminance of #bg must stay below 0.5)
python3 - "$root/config/wallust/colorschemes" <<'PY' && ok "all themes are dark" || bad "a light theme is in the carousel"
import json, glob, sys
bad = []
for f in glob.glob(sys.argv[1] + "/omarchy-*.json"):
    h = json.load(open(f))["special"]["background"].lstrip("#")
    c = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    if 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2] >= 0.5: bad.append(f.split("/")[-1])
sys.exit("light themes: %s" % bad if bad else 0)
PY

# theme carousel: every color scheme is complete, and applying one writes its accent into the hypr colors file
if command -v python3 >/dev/null; then
  out=$(python3 - "$root/config/wallust/colorschemes" <<'PY' 2>&1
import json, glob, re, sys
bad = []
for f in sorted(glob.glob(sys.argv[1] + "/omarchy-*.json")):
    d = json.load(open(f))
    cols = [d["colors"].get("color%d" % i, "") for i in range(16)] + [d["special"].get(k, "") for k in ("background", "foreground", "cursor")]
    if not all(re.fullmatch(r"#[0-9a-fA-F]{6}", c) for c in cols): bad.append(f.split("/")[-1])
sys.exit("incomplete schemes: %s" % bad if bad else 0)
PY
)
  [ -z "$out" ] && ok "all omarchy color schemes have 16 colors + special" || bad "color schemes" "$out"
fi
if command -v wallust >/dev/null; then
  wl="$tmp/wl"; wh="$tmp/wlhome"; mkdir -p "$wl" "$wh/.config"; cp -r "$root"/config/wallust/* "$wl/"
  for d in cava hypr/wallust rofi/wallust waybar/wallust kitty quickshell; do mkdir -p "$wh/.config/$d"; done; mkdir -p "$wh/.local/share/themes/relian/gtk-3.0"
  names=$(env HOME="$wh" WALLUST_CONFIG_DIR="$wl" "$root/config/hypr/scripts/ThemeSelect.sh" --list 2>&1)
  [ "$(echo "$names" | wc -l)" -ge 17 ] && ok "ThemeSelect --list shows wallpaper + themes" || bad "ThemeSelect --list" "$names"
  out=$(env HOME="$wh" WALLUST_CONFIG_DIR="$wl" THEME_NO_RELOAD=1 XDG_CACHE_HOME="$wh/.cache" "$root/config/hypr/scripts/ThemeSelect.sh" --set "Tokyo Night" 2>&1)
  grep -q 'color12 = "rgb(7AA2F7)"' "$wh/.config/hypr/wallust/wallust-hyprland.lua" && ok "ThemeSelect --set writes Tokyo Night accent" || bad "ThemeSelect --set" "$out"
  # every theme must apply, and land its own accent (color12) in the hypr colors file
  fails=""
  for f in "$root"/config/wallust/colorschemes/omarchy-*.json; do
    nm=$(basename "$f" .json); nm=${nm#omarchy-}; pn=$(for w in ${nm//-/ }; do printf '%s ' "${w^}"; done); pn=${pn% }
    env HOME="$wh" WALLUST_CONFIG_DIR="$wl" THEME_NO_RELOAD=1 XDG_CACHE_HOME="$wh/.cache" "$root/config/hypr/scripts/ThemeSelect.sh" --set "$pn" >/dev/null 2>&1
    want=$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['colors']['color12'].lstrip('#').upper())" "$f")
    grep -q "color12 = \"rgb($want)\"" "$wh/.config/hypr/wallust/wallust-hyprland.lua" || fails+="$pn "
  done
  [ -z "$fails" ] && ok "every theme applies with its own accent" || bad "themes that failed to apply" "$fails"
  env HOME="$wh" WALLUST_CONFIG_DIR="$wl" THEME_NO_RELOAD=1 XDG_CACHE_HOME="$wh/.cache" "$root/config/hypr/scripts/ThemeSelect.sh" --set "Tokyo Night" >/dev/null 2>&1
  nxt=$(env HOME="$wh" WALLUST_CONFIG_DIR="$wl" THEME_NO_RELOAD=1 XDG_CACHE_HOME="$wh/.cache" "$root/config/hypr/scripts/ThemeSelect.sh" --next 2>&1)
  [ "$nxt" = "Vantablack" ] && ok "ThemeSelect --next cycles (Tokyo Night -> Vantablack)" || bad "ThemeSelect --next" "got: $nxt"
fi

# rofi: highlighted rows stay readable on every theme (text vs highlight contrast >= 3:1; the template picks light/dark text)
if command -v wallust >/dev/null && command -v python3 >/dev/null; then
  out=$(python3 - "$root" "$tmp" <<'PY' 2>&1
import re, subprocess, sys, os, glob, shutil
root, S = sys.argv[1], sys.argv[2]
def lum(h):
    c=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    c=[x/12.92 if x<=0.03928 else ((x+0.055)/1.055)**2.4 for x in c]
    return 0.2126*c[0]+0.7152*c[1]+0.0722*c[2]
def cr(a,b):
    la,lb=sorted((lum(a),lum(b)),reverse=True); return (la+0.05)/(lb+0.05)
pairs=[("active","active"),("urgent","urgent"),("selected-normal","selected-normal"),("selected-active","selected-active"),("selected-urgent","selected-urgent"),("alternate-active","alternate-active")]
worst=(99,"")
for f in sorted(glob.glob(root+"/config/wallust/colorschemes/omarchy-*.json")):
    wl,wh=S+"/c_wl",S+"/c_wh"
    shutil.rmtree(wl,ignore_errors=True); shutil.rmtree(wh,ignore_errors=True)
    shutil.copytree(root+"/config/wallust",wl)
    for d in ("cava","hypr/wallust","rofi/wallust","waybar/wallust","kitty","quickshell"): os.makedirs(wh+"/.config/"+d)
    subprocess.run(["wallust","-d",wl,"-q","-s","cs",os.path.basename(f)],env={**os.environ,"HOME":wh},check=True,capture_output=True)
    t=open(wh+"/.config/rofi/wallust/colors-rofi.rasi").read()
    g=lambda k: re.search(r"^%s:\s*#([0-9A-Fa-f]{6})"%k,t,re.M).group(1)
    for a,_ in pairs:
        r=cr(g(a+"-background"),g(a+"-foreground"))
        if r<worst[0]: worst=(r,"%s %s"%(os.path.basename(f),a))
print("worst contrast %.2f at %s"%worst)
sys.exit(0 if worst[0] >= 3.0 else 1)
PY
)
  [ $? -eq 0 ] && ok "rofi highlight text contrast >= 3:1 on all themes ($out)" || bad "rofi highlight contrast too low" "$out"
fi

# SensorTemps.sh always prints valid JSON (even with no sensors); layout wires speed + temps into the centre
out=$("$root/config/hypr/scripts/SensorTemps.sh" 2>&1)
echo "$out" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); assert "text" in d and d["class"] in ("ok","warm","hot","hidden")' 2>&1 && ok "SensorTemps.sh prints valid waybar JSON" || bad "SensorTemps.sh output" "$out"
grep -q '"modules-center": \["network#speed", "clock", "custom/weather", "custom/temps"\]' "$root/config/waybar/configs/[TOP] Omarchy" && ok "waybar centre = speed, clock, weather, temps" || bad "waybar centre modules"

# kitty follows the wallust theme and has Omarchy-style settings; swaync cards are square
grep -q '^include ./kitty-themes/01-Wallust.conf' "$root/config/kitty/kitty.conf" && ! grep -qE '^(foreground|background|cursor) ' "$root/config/kitty/kitty.conf" && ok "kitty includes the wallust theme (no static colors)" || bad "kitty.conf colors"
grep -qE '^window_padding_width 14' "$root/config/kitty/kitty.conf" && grep -q '^cursor_shape block' "$root/config/kitty/kitty.conf" && ok "kitty: 14px padding, block cursor" || bad "kitty padding/cursor"
grep -E 'radius' "$root/config/swaync/style.css" | grep -qvE 'radius: 0' && bad "swaync has rounded corners" || ok "swaync corners are square (every radius is 0)"
grep -q '\.notification-action button' "$root/config/swaync/style.css" && ok "swaync styles the notification action buttons" || bad "swaync action buttons unstyled"
python3 -c 'import json,sys; c=json.load(open(sys.argv[1])); assert c["positionX"]=="right" and c["notification-window-width"]==380' "$root/config/swaync/config.json" 2>&1 && ok "swaync: top-right, 380px" || bad "swaync config"

# AgentUsage.sh merges claudebar + codexbar into one waybar module (stand-in commands, never real credentials)
if command -v jq >/dev/null; then
  stub="$tmp/stub"; mkdir -p "$stub"; nohome="$tmp/nohome"; mkdir -p "$nohome"
  # PATH for the tests: only core tools symlinked into a private dir. /usr/bin is NOT used, because the real
  # claudebar/codexbar may be installed there and would be run against your real credentials.
  core="$tmp/core"; mkdir -p "$core"; for b in bash env jq timeout date cat sed tr head sleep dirname basename; do p=$(command -v "$b") && ln -sf "$p" "$core/$b"; done
  printf '%s\n' '#!/usr/bin/env bash' 'n=$(date +%s)' 'echo "{\"error\":null,\"plan\":\"max\",\"state\":\"high\",\"max_pct\":73,\"windows\":[{\"label\":\"Weekly (7d)\",\"used_pct\":73,\"reset_at_unix\":$((n+200000))}]}"' > "$stub/claudebar"
  printf '%s\n' '#!/usr/bin/env bash' 'n=$(date +%s)' 'echo "{\"error\":null,\"plan\":\"plus\",\"state\":\"low\",\"max_pct\":12,\"windows\":[{\"label\":\"Session <5h>\",\"used_pct\":12,\"reset_at_unix\":$((n+1800))}]}"' > "$stub/codexbar"
  chmod +x "$stub"/*
  au="$root/config/hypr/scripts/AgentUsage.sh"
  out=$(HOME="$nohome" PATH="$stub:$core" "$au")
  echo "$out" | jq -e '(.text | endswith("73%")) and .class == "high" and (.tooltip | contains("Claude Code")) and (.tooltip | contains("max")) and (.tooltip | contains("Codex")) and (.tooltip | contains("plus")) and (.tooltip | contains("&lt;"))' >/dev/null 2>&1 \
    && ok "AgentUsage.sh merges both agents (icon + fullest %, worst class, escaped tooltip)" || bad "AgentUsage.sh merge" "$out"
  out=$(HOME="$nohome" PATH="$core" "$au")
  echo "$out" | jq -e '.class == "missing" and (.tooltip | contains("yay -S claudebar")) and (.tooltip | contains("yay -S codexbar"))' >/dev/null 2>&1 \
    && ok "AgentUsage.sh without the tools still shows an icon and the install hint" || bad "AgentUsage.sh missing tools" "$out"
  printf '%s\n' '#!/usr/bin/env bash' 'echo "{\"error\":{\"message\":\"No credentials. Run claude\"}}"' > "$stub/claudebar"
  out=$(HOME="$nohome" PATH="$stub:$core" "$au")
  echo "$out" | jq -e '(.tooltip | contains("No credentials")) and .class == "low"' >/dev/null 2>&1 \
    && ok "AgentUsage.sh shows one agent's error without hiding the other" || bad "AgentUsage.sh error handling" "$out"
fi
if python3 -c 'import gi; gi.require_version("Pango","1.0")' 2>/dev/null; then
  out=$(HOME="$nohome" PATH="$stub:$core" "$au" | jq -r .tooltip | python3 -c 'import sys,gi; gi.require_version("Pango","1.0"); from gi.repository import Pango; Pango.parse_markup(sys.stdin.read(),-1,"\0")' 2>&1) \
    && ok "AgentUsage.sh tooltip is valid Pango markup" || bad "AgentUsage.sh tooltip markup" "$out"
fi
grep -q 'AgentPrompt.sh' "$root/config/waybar/configs/[TOP] Omarchy" && grep -q '"SUPER + CTRL + A"' "$root/config/hypr/configs/Keybinds.lua" && ok "agents icon + SUPER+CTRL+A open the agent prompt" || bad "agent prompt wiring"

# rebrand guard: no leftover upstream branding outside the license, changelog, NOTICE and the two external installer URLs
left=$(cd "$root" && git grep -n -I -i 'k[o]ol' -- . ':!LICENSE.md' ':!CHANGELOG.md' ':!NOTICE' ':!tests/run.sh' 2>/dev/null | grep -vE 'github\.com/JaK[o]oLit/(\$Distro|Wallpaper-Bank)\.git')
[ -z "$left" ] && ok "no upstream branding left (besides license/NOTICE/changelog/installer URLs)" || bad "upstream branding found" "$left"

# rofi menu header messages are plain text (emoji render as ugly colour glyphs in rofi)
emo=$(grep -rnP '^\s*msg=.*[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{2049}\x{203C}\x{FE0F}]' "$root/config/hypr/scripts" "$root/config/hypr/UserScripts" 2>/dev/null)
emo+=$(grep -rnP 'placeholder:.*[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{2049}\x{203C}\x{FE0F}]' "$root/config/rofi" 2>/dev/null)
[ -z "$emo" ] && ok "rofi menu messages and search placeholders have no emoji" || bad "emoji in rofi menu messages/placeholders" "$emo"

# rofi custom keys must not overlap rofi's own defaults (it pops a warning): the defaults they collide with are freed first
grep -q 'kb-accept-alt ""' "$root/config/hypr/scripts/AgentPrompt.sh" && ok "AgentPrompt frees rofi's Shift+Return before binding it" || bad "AgentPrompt Shift+Return overlaps rofi kb-accept-alt"
grep -q 'kb-row-up' "$root/config/hypr/scripts/ThemeSelect.sh" && grep -q 'kb-move-char-back' "$root/config/hypr/scripts/ThemeSelect.sh" && ok "ThemeSelect frees rofi's arrow-key bindings" || bad "ThemeSelect arrow keys overlap rofi defaults"

# the top-left waybar icon opens the same (Omarchy-style) main menu as SUPER+SPACE
python3 - "$root/config/waybar/configs/[TOP] Omarchy" "$root/config/hypr/scripts/Relian_Quick_Settings.sh" <<'PY' && ok "waybar menu icon = SUPER+SPACE main menu, themed like the launcher" || bad "waybar menu icon / menu theme"
import re, sys, json
t = open(sys.argv[1], encoding="utf-8").read()
t = re.sub(r'/\*.*?\*/', '', t, flags=re.S); t = re.sub(r'^\s*//.*$', '', t, flags=re.M)
assert "Relian_Quick_Settings.sh" in json.loads(t)["custom/menu"]["on-click"]
assert "config-omarchy-menu.rasi" in open(sys.argv[2], encoding="utf-8").read()
PY

# launcher search: match only name/generic name (hidden categories/keywords made "file" list Steam first); keep history
grep -q 'drun-match-fields: "name,generic"' "$root/config/rofi/config-omarchy-launcher.rasi" && grep -q 'disable-history: false' "$root/config/rofi/config-omarchy-launcher.rasi" && ok "launcher matches name/generic only and keeps usage history" || bad "launcher search settings"
grep -q 'window.thunar' "$root/config/gtk-theme/relian/gtk-3.0/relian-thunar.css" && ok "thunar square-corner css is scoped to window.thunar" || bad "thunar css scope"

# GTK follows the wallust theme: applying a theme writes the adw-gtk3 colour names with that theme's accent
gtkcss="$wh/.local/share/themes/relian/gtk-3.0/gtk.css"
if command -v wallust >/dev/null && [ -d "$wh" ]; then
  env HOME="$wh" WALLUST_CONFIG_DIR="$wl" THEME_NO_RELOAD=1 XDG_CACHE_HOME="$wh/.cache" "$root/config/hypr/scripts/ThemeSelect.sh" --set "Tokyo Night" >/dev/null 2>&1
  grep -q '@define-color accent_bg_color #7AA2F7;' "$gtkcss" 2>/dev/null && grep -q 'adw-gtk3-dark/gtk-3.0/gtk.css' "$gtkcss" \
    && ok "GTK theme 'relian' is written with the theme's accent on top of adw-gtk3-dark" || bad "GTK theme file" "$(head -c 300 "$gtkcss" 2>/dev/null)"
fi
grep -q 'window.thunar' "$root/config/gtk-theme/relian/gtk-3.0/relian-thunar.css" && grep -q 'JetBrainsMono' "$root/config/gtk-theme/relian/gtk-3.0/relian-thunar.css" && ok "thunar css: scoped, square, JetBrainsMono" || bad "thunar css"

# kitty transparency can be toggled from outside: dynamic opacity ON (must be 'yes', '1' is read as off) + socket remote control
grep -qE '^dynamic_background_opacity yes' "$root/config/kitty/kitty.conf" && grep -q '^allow_remote_control socket-only' "$root/config/kitty/kitty.conf" && grep -q '^listen_on unix:@kitty$' "$root/config/kitty/kitty.conf" \
  && ok "kitty: dynamic opacity + socket remote control (needed by the opacity toggle)" || bad "kitty opacity settings"

# kitty must not restore the last window's size/maximized state, or one maximized close makes every new terminal maximized
grep -qE '^remember_window_size no' "$root/config/kitty/kitty.conf" && ok "kitty: remember_window_size no (new terminals always tile)" || bad "kitty remembers window state (new terminals can start maximized)"

# opacity toggle must not use the removed `hyprctl setprop`; it reads the state and sets the opposite
grep -q 'ToggleOpaque.sh' "$root/config/hypr/configs/Keybinds.lua" && ! grep -q 'value = "toggle"' "$root/config/hypr/configs/Keybinds.lua" && ok "opacity bind uses ToggleOpaque.sh (no setprop toggle)" || bad "opacity toggle bind"

# power menu (wlogout): square tiles, no bouncy hover
grep -E 'radius' "$root/config/wlogout/style.css" | grep -qvE 'radius: 0' && bad "wlogout has rounded buttons" || ok "wlogout power menu is square"

# the Omarchy-style waybar layout is valid JSONC and its style imports the wallust colors
if command -v python3 >/dev/null; then
  out=$(python3 - "$root/config/waybar/configs/[TOP] Omarchy" <<'PY' 2>&1
import re, sys, json
t = open(sys.argv[1], encoding="utf-8").read()
t = re.sub(r'/\*.*?\*/', '', t, flags=re.S); t = re.sub(r'^\s*//.*$', '', t, flags=re.M)
c = json.loads(t)
mods = [m for k in ("modules-left", "modules-center", "modules-right") for m in c[k]]
missing = [m for m in mods if m not in c]
sys.exit("modules listed but not defined: %s" % missing if missing else 0)
PY
)
  [ -z "$out" ] && ok "waybar [TOP] Omarchy: valid JSONC, every listed module defined" || bad "waybar [TOP] Omarchy" "$out"
fi
grep -q "colors-waybar.css" "$root/config/waybar/style/[Omarchy] Minimal.css" && ok "waybar [Omarchy] Minimal imports wallust colors" || bad "waybar Omarchy style missing wallust import"

# the installer works in an empty home, installs everything, and keeps your own edits on re-run (--force resets them)
if command -v rsync >/dev/null; then
  ih="$tmp/ihome"; mkdir -p "$ih"
  run_install() { HOME="$ih" XDG_CACHE_HOME="$ih/.cache" "$root/install.sh" --files-only "$@" >"$tmp/install.log" 2>&1; }
  if run_install; then
    miss=""
    for f in .config/hypr/hyprland.lua .config/hypr/UserConfigs/UserKeybinds.lua .config/hypr/monitors.lua .config/hypr/scripts/ThemeSelect.sh \
             .config/waybar/config .config/waybar/style.css .config/rofi/config-omarchy-launcher.rasi .config/kitty/kitty.conf \
             .config/hypr/wallpaper_effects/.wallpaper_current .local/share/themes/relian/index.theme .local/share/themes/relian/gtk-3.0/gtk.css; do
      [ -e "$ih/$f" ] || miss+="$f "
    done
    grep -q 'gtk-theme-name=relian' "$ih/.config/gtk-3.0/settings.ini" 2>/dev/null || miss+="settings.ini "
    [ -z "$miss" ] && ok "install.sh installs everything into an empty home" || bad "install.sh left things out" "$miss"
    echo "-- user edit marker" >> "$ih/.config/hypr/UserConfigs/UserKeybinds.lua"
    run_install
    grep -q "user edit marker" "$ih/.config/hypr/UserConfigs/UserKeybinds.lua" && ok "install.sh re-run keeps your UserConfigs edits" || bad "install.sh overwrote UserConfigs"
    run_install --force
    grep -q "user edit marker" "$ih/.config/hypr/UserConfigs/UserKeybinds.lua" && bad "install.sh --force did not reset UserConfigs" || ok "install.sh --force resets them to the defaults"
  else bad "install.sh failed in an empty home" "$(tail -5 "$tmp/install.log")"; fi
fi

# docs/KEYBINDINGS.md is generated from the Lua bind files and must be current
python3 "$root/tools/gen-keybindings-doc.py" --check && ok "docs/KEYBINDINGS.md is up to date" || bad "docs/KEYBINDINGS.md is out of date (run tools/gen-keybindings-doc.py)"

# every require() in hyprland.lua resolves to a file
for m in $(grep -oE 'require\("[^"]+"\)' "$root/config/hypr/hyprland.lua" | sed 's/require("\(.*\)")/\1/'); do
  [ -f "$root/config/hypr/$(echo "$m" | tr . /).lua" ] && ok "require $m" || bad "require $m has no file"
done

exit $fail

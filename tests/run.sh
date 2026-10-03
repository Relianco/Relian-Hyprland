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
for f in "$root"/config/hypr/scripts/* "$root"/config/hypr/UserScripts/*.sh "$root"/config/hypr/initial-boot.sh "$root"/copy.sh; do
  case "$f" in *.sh) ;; *) head -1 "$f" 2>/dev/null | grep -q 'bash' || continue ;; esac
  [ "$(basename "$f")" = RofiEmoji.sh ] && continue # upstream: emoji data blob after `exit`, bash -n can't parse it
  out=$(bash -n "$f" 2>&1) && ok "bash -n $(basename "$f")" || bad "bash -n $(basename "$f")" "$out"
done

# regression guard: legacy hyprlang-only calls break under a Lua config
out=$(grep -rnE "hyprctl (keyword|--batch|setprop)|hyprctl dispatch [a-z_]+( |$)" "$root/config" --include=* -I 2>/dev/null \
      | grep -vE "hl\.dsp|:[0-9]+:\s*(#|--)|\.md:|RainbowBorders.bak.sh|hyprlock|README|Laptops.lua" )
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

# squares and no rainbow: rounding stays 0 and the rotating-border animation stays out
grep -qE 'rounding = 0,' "$root/config/hypr/UserConfigs/UserDecorations.lua" && ok "corners are square (rounding = 0)" || bad "rounding is not 0"
grep -q 'borderangle' "$root/config/hypr/UserConfigs/UserAnimations.lua" && bad "rainbow border animation present" || ok "no rainbow border animation"

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
  for d in cava hypr/wallust rofi/wallust waybar/wallust kitty quickshell; do mkdir -p "$wh/.config/$d"; done
  names=$(env HOME="$wh" WALLUST_CONFIG_DIR="$wl" "$root/config/hypr/scripts/ThemeSelect.sh" --list 2>&1)
  [ "$(echo "$names" | wc -l)" -ge 22 ] && ok "ThemeSelect --list shows wallpaper + themes" || bad "ThemeSelect --list" "$names"
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

# every require() in hyprland.lua resolves to a file
for m in $(grep -oE 'require\("[^"]+"\)' "$root/config/hypr/hyprland.lua" | sed 's/require("\(.*\)")/\1/'); do
  [ -f "$root/config/hypr/$(echo "$m" | tr . /).lua" ] && ok "require $m" || bad "require $m has no file"
done

exit $fail

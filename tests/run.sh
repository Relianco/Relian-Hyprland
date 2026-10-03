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

# every require() in hyprland.lua resolves to a file
for m in $(grep -oE 'require\("[^"]+"\)' "$root/config/hypr/hyprland.lua" | sed 's/require("\(.*\)")/\1/'); do
  [ -f "$root/config/hypr/$(echo "$m" | tr . /).lua" ] && ok "require $m" || bad "require $m has no file"
done

exit $fail

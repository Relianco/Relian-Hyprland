#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# Runs inside the screensaver terminal (started by Screensaver.sh): text effects until a key is pressed or the window
# loses focus, then restores the cursor and exits (which closes the terminal).

# Art lives in ~/.config/hypr/branding/large/*.txt (needs ~42 terminal rows) and small/*.txt (shorter screens). A random
# one is picked each time the effect (re)starts; drop your own .txt files in to add to the mix.
BRANDING="$HOME/.config/hypr/branding"
CLASS=org.relian.screensaver

set_cursor_hidden() { # 1 = hide, 0 = show. Lua config: eval; old format: keyword. (hyprctl exits 0 either way, so read the reply)
  local v=false; [ "$1" = 1 ] && v=true
  hyprctl eval "hl.config({ cursor = { invisible = $v } })" 2>&1 | grep -qx ok ||
    hyprctl keyword cursor:invisible "$v" >/dev/null 2>&1 || true
}

in_focus() { hyprctl activewindow -j 2>/dev/null | jq -e --arg c "$CLASS" '.class == $c' >/dev/null 2>&1; }

finish() { set_cursor_hidden 0; pkill -x -t "$(tty 2>/dev/null | sed 's|/dev/||')" ttfx 2>/dev/null; exit 0; }
trap finish SIGINT SIGTERM SIGHUP SIGQUIT

printf '\033]11;rgb:00/00/00\007'     # black background
set_cursor_hidden 1
tty=$(tty 2>/dev/null)

# the pty starts at 80x24 and is resized once the compositor has sized the window; ttfx measures once at start-up
for _ in $(seq 1 100); do [[ $(stty size 2>/dev/null) == "24 80" ]] && sleep 0.02 || break; done

pick_logo() {
  local rows dir files
  rows=$(stty size 2>/dev/null | cut -d" " -f1)
  dir="$BRANDING/large"; [ "${rows:-0}" -ge 42 ] || dir="$BRANDING/small"
  files=("$dir"/*.txt)
  [ -f "${files[0]}" ] && printf '%s\n' "${files[RANDOM % ${#files[@]}]}" || printf '%s\n' "$BRANDING/screensaver.txt"
}

while true; do
  ttfx -i "$(pick_logo)" --frame-rate 120 --canvas-width 0 --canvas-height 0 --reuse-canvas --anchor-canvas c --anchor-text c \
    --random-effect --no-eol --no-restore-cursor &
  while pgrep -t "${tty#/dev/}" -x ttfx >/dev/null; do
    if read -rn1 -t 1 || ! in_focus; then finish; fi
  done
done

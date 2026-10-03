#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# Screensaver: a fullscreen kitty on every monitor running random terminal text effects (ttfx) over the logo in
# ~/.config/hypr/branding/screensaver.txt. Any key or mouse move ends it. Idea and structure follow Omarchy's (MIT).
#   Screensaver.sh           start it (used by hypridle after the idle timeout); does nothing if switched off
#   Screensaver.sh force     start it even if switched off (the "preview" in the menu)
#   Screensaver.sh toggle    switch the idle screensaver on/off
# Needs ttfx (AUR: yay -S ttfx). Windows get class org.relian.screensaver; the rules that make them fullscreen are in
# WindowRules (Lua) / WindowRules.conf.

CLASS=org.relian.screensaver
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/relian/screensaver-off"   # file present = switched off
RUN="$HOME/.config/hypr/scripts/ScreensaverRun.sh"

if [ "${1:-}" = toggle ]; then
  mkdir -p "$(dirname "$STATE")"
  if [ -f "$STATE" ]; then rm -f "$STATE"; msg="Screensaver enabled"; else : > "$STATE"; msg="Screensaver disabled"; fi
  notify-send -u low "$msg"; echo "$msg"; exit 0
fi

# already running?
hyprctl clients -j 2>/dev/null | jq -e --arg c "$CLASS" 'any(.[]; .class == $c)' >/dev/null 2>&1 && exit 0
[ "${1:-}" = force ] || ! [ -f "$STATE" ] || exit 1

command -v ttfx >/dev/null 2>&1 || { notify-send -u normal "Screensaver needs ttfx" "Install it: yay -S ttfx"; exit 1; }

focus_monitor() {
  hyprctl dispatch "hl.dsp.focus({ monitor = \"$1\" })" 2>&1 | grep -qx ok || hyprctl dispatch focusmonitor "$1" >/dev/null 2>&1
}

# open a kitty on <workspace>: Lua dispatcher first, the old-format dispatcher as fallback
spawn() { # spawn <workspace>
  local ws=$1 cmd
  printf -v cmd '%q ' kitty --class "$CLASS" --override font_size=18 --override window_padding_width=0 \
    --override background_opacity=1 --override remember_window_size=no "$RUN"
  hyprctl dispatch "hl.dsp.exec_cmd([[[workspace $ws] $cmd]])" 2>&1 | grep -qx ok ||
    hyprctl dispatch exec "[workspace $ws]" "$cmd" >/dev/null 2>&1
}

wait_for_window() { # wait (up to 5s) until another screensaver window exists beyond $1
  local want=$1 i
  for i in $(seq 1 50); do
    [ "$(hyprctl clients -j | jq --arg c "$CLASS" '[.[] | select(.class == $c)] | length')" -ge "$want" ] && return 0
    sleep 0.1
  done
}

orig=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
n=0
while read -r m; do
  focus_monitor "$m"
  spawn "special:screensaver-$m"
  n=$((n + 1)); wait_for_window "$n"
done < <(hyprctl monitors -j | jq -r '.[].name')
[ -n "$orig" ] && focus_monitor "$orig"
exit 0

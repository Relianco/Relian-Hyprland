#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Volume popup (click the speaker in Waybar): a big meter, Left/Right change the volume, rows to mute, pick the output, mute the mic.
#   Left/Right  -/+ 5%     Enter  run the row     Esc  close
. "$HOME/.config/hypr/scripts/PopupLib.sh"
sink='@DEFAULT_AUDIO_SINK@'; src='@DEFAULT_AUDIO_SOURCE@'

state() { # -> "PERCENT muted|on"
  local v; v=$(wpctl get-volume "$sink" 2>/dev/null) || { echo "0 muted"; return; }
  local n=${v#Volume: }; n=${n%% *}
  awk -v n="$n" -v m="$v" 'BEGIN { printf "%d %s\n", n * 100 + 0.5, (m ~ /MUTED/ ? "muted" : "on") }'
}

while true; do
  read -r pct muted < <(state)
  sinks=(); names=()
  default=$(pactl get-default-sink 2>/dev/null)
  while IFS=$'\t' read -r n d; do sinks+=("$n"); names+=("$d"); done < <(pactl -f json list sinks 2>/dev/null | jq -r '.[] | [.name, .description] | @tsv')
  cur_desc=""; for i in "${!sinks[@]}"; do [ "${sinks[i]}" = "$default" ] && cur_desc=${names[i]}; done
  micmuted=$(wpctl get-volume "$src" 2>/dev/null | grep -q MUTED && echo yes || echo no)

  icon="󰕾"; [ "$pct" -lt 34 ] && icon="󰕿"; [ "$pct" -ge 34 ] && [ "$pct" -lt 67 ] && icon="󰖀"; [ "$muted" = muted ] && icon="󰝟"
  mesg="<span size=\"x-large\" weight=\"bold\" foreground=\"$accent\">$icon  $pct%</span>$([ "$muted" = muted ] && printf '  <span alpha=\"55%%\">muted</span>')
$(meter "$pct" 30)
<span alpha=\"55%\">$(esc "${cur_desc:0:48}")</span>
<span size=\"small\" alpha=\"40%\">←/→ volume   Enter select   Esc close</span>"

  rows=()
  [ "$muted" = muted ] && rows+=("󰕾  Unmute") || rows+=("󰝟  Mute")
  [ "$micmuted" = yes ] && rows+=("󰍬  Unmute microphone") || rows+=("󰍭  Mute microphone")
  for i in "${!sinks[@]}"; do
    mark="  "; [ "${sinks[i]}" = "$default" ] && mark="\u2713 "
    rows+=("$(printf '%b' "$mark")$(esc "${names[i]:0:44}")")
  done
  rows+=("󰒓  Open mixer")

  choice=$(printf '%s\n' "${rows[@]}" | rofi -dmenu -i -no-custom -markup-rows -format i -theme "$popup_theme" -mesg "$mesg" "${popup_keys[@]}" \
    -kb-custom-1 "Left" -kb-custom-2 "Right")
  rc=$?
  case $rc in
    10) wpctl set-volume "$sink" 5%- ;;
    11) wpctl set-volume -l 1.0 "$sink" 5%+ ;;
    0)  case $choice in
          0) wpctl set-mute "$sink" toggle ;;
          1) wpctl set-mute "$src" toggle ;;
          *) n=$((choice - 2))
             if [ "$n" -ge 0 ] && [ "$n" -lt "${#sinks[@]}" ]; then pactl set-default-sink "${sinks[n]}"
             else pavucontrol >/dev/null 2>&1 & exit 0; fi ;;
        esac ;;
    *) exit 0 ;;
  esac
done

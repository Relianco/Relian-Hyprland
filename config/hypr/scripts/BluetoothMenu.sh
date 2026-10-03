#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Bluetooth popup (click the Bluetooth icon in Waybar): devices with their state, Enter connects/disconnects (or pairs a new one),
# rows to power Bluetooth on/off and scan for new devices. Uses bluetoothctl.
. "$HOME/.config/hypr/scripts/PopupLib.sh"
notify() { notify-send -a "Bluetooth" "$1" "${2:-}" 2>/dev/null; }

devices() { # lines: MAC<TAB>name<TAB>paired<TAB>connected   (connected first, then paired, then new)
  local mac name info
  while read -r _ mac name; do
    [ -n "$mac" ] || continue
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    printf '%s\t%s\t%s\t%s\n' "$mac" "$name" "$(grep -q 'Paired: yes' <<<"$info" && echo 1 || echo 0)" "$(grep -q 'Connected: yes' <<<"$info" && echo 1 || echo 0)"
  done < <(bluetoothctl devices 2>/dev/null) | sort -t$'\t' -k4,4nr -k3,3nr -k2,2f
}

scan=0
while true; do
  powered=$(bluetoothctl show 2>/dev/null | sed -n 's/.*Powered: //p')
  mesg="<span size=\"x-large\" weight=\"bold\" foreground=\"$accent\">󰂯  Bluetooth</span>
<span alpha=\"60%\">$([ "$powered" = yes ] && echo 'on' || echo 'turned off')</span>"
  rows=(); acts=()
  if [ "$powered" = yes ]; then
    rows+=("󰂲  Turn Bluetooth off"); acts+=("off"); rows+=("󰑓  Scan for new devices (10 s)"); acts+=("scan")
    while IFS=$'\t' read -r mac name paired conn; do
      if [ "$conn" = 1 ]; then rows+=("󰂱  $(esc "$name")   <span alpha=\"55%\">connected</span>")
      elif [ "$paired" = 1 ]; then rows+=("󰂯  $(esc "$name")")
      else rows+=("󰐱  $(esc "$name")   <span alpha=\"55%\">new, Enter pairs</span>"); fi
      acts+=("dev:$mac:$paired:$conn:$name")
    done < <(devices)
  else rows+=("󰂯  Turn Bluetooth on"); acts+=("on")
  fi
  rows+=("󰒓  Advanced settings"); acts+=("adv")

  choice=$(printf '%s\n' "${rows[@]}" | rofi -dmenu -i -no-custom -markup-rows -format i -selected-row "$([ "$powered" = yes ] && echo 2 || echo 0)" -theme "$popup_theme" -mesg "$mesg" "${popup_keys[@]}")
  [ $? -eq 0 ] || exit 0
  case ${acts[choice]} in
    off) bluetoothctl power off >/dev/null ;;
    on)  rfkill unblock bluetooth 2>/dev/null; bluetoothctl power on >/dev/null; sleep 1 ;;
    scan) timeout 11 bluetoothctl --timeout 10 scan on >/dev/null 2>&1 ;;
    adv) blueman-manager >/dev/null 2>&1 & exit 0 ;;
    dev:*) IFS=: read -r _ m1 m2 m3 m4 m5 m6 paired conn name <<<"${acts[choice]}"; mac="$m1:$m2:$m3:$m4:$m5:$m6"
           if [ "$conn" = 1 ]; then bluetoothctl disconnect "$mac" >/dev/null && notify "Disconnected" "$name"
           elif [ "$paired" = 1 ]; then bluetoothctl connect "$mac" >/dev/null 2>&1 && notify "Connected" "$name" || notify "Could not connect" "$name"
           else bluetoothctl pair "$mac" >/dev/null 2>&1 && bluetoothctl trust "$mac" >/dev/null 2>&1 && bluetoothctl connect "$mac" >/dev/null 2>&1 \
                  && notify "Paired" "$name" || notify "Could not pair" "$name"; fi ;;
  esac
done

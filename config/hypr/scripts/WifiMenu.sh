#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Wi-Fi popup (click the Wi-Fi icon in Waybar): networks by signal, Enter connects (asks for a password the first time),
# rows to turn Wi-Fi on/off and rescan. Uses NetworkManager (nmcli).
. "$HOME/.config/hypr/scripts/PopupLib.sh"
bars=(󰤯 󰤟 󰤢 󰤥 󰤨)

list_networks() { # -> lines: ssid<TAB>signal<TAB>security<TAB>inuse (strongest entry per SSID)
  nmcli -t --escape no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list 2>/dev/null |
    awk -F: '{ ssid=$4; for (i=5; i<=NF; i++) ssid=ssid ":" $i
               if (ssid == "") next
               if (!(ssid in sig) || $2+0 > sig[ssid]+0) { sig[ssid]=$2; sec[ssid]=$3; use[ssid]=($1 == "*") }
               if ($1 == "*") use[ssid]=1 }
             END { for (s in sig) printf "%s\t%s\t%s\t%s\n", s, sig[s], sec[s], use[s] }' | sort -t$'\t' -k4,4nr -k2,2nr
}

notify() { notify-send -a "Wi-Fi" "$1" "${2:-}" 2>/dev/null; }

connect() { # connect SSID SECURITY
  local ssid=$1 sec=$2 pw
  if nmcli -t -f NAME con show | grep -Fxq -- "$ssid"; then
    nmcli con up id "$ssid" >/dev/null 2>&1 && notify "Connected" "$ssid" || notify "Could not connect" "$ssid"
  elif [ -z "$sec" ] || [ "$sec" = "--" ]; then
    nmcli dev wifi connect "$ssid" >/dev/null 2>&1 && notify "Connected" "$ssid" || notify "Could not connect" "$ssid"
  else
    pw=$(printf '' | rofi -dmenu -password -theme "$popup_theme" -theme-str 'listview { lines: 0; }' -mesg "Password for <b>$(esc "$ssid")</b>" "${popup_keys[@]}") || return
    # the password goes in on stdin (--ask), never on the command line where other users' ps could see it
    printf '%s\n' "$pw" | nmcli --ask dev wifi connect "$ssid" >/dev/null 2>&1 && notify "Connected" "$ssid" || notify "Could not connect" "$ssid" "wrong password?"
  fi
}

while true; do
  radio=$(nmcli radio wifi 2>/dev/null)
  cur=$(nmcli -t --escape no -f ACTIVE,SSID dev wifi 2>/dev/null | sed -n 's/^yes://p' | head -1)
  mesg="<span size=\"x-large\" weight=\"bold\" foreground=\"$accent\">󰖩  Wi-Fi</span>
<span alpha=\"60%\">$([ "$radio" = enabled ] && { [ -n "$cur" ] && printf 'connected to %s' "$(esc "$cur")" || printf 'not connected'; } || printf 'turned off')</span>"
  rows=(); acts=(); sel=0
  if [ "$radio" = enabled ]; then rows+=("󰖪  Turn Wi-Fi off"); acts+=("off"); rows+=("󰑓  Rescan"); acts+=("scan")
    while IFS=$'\t' read -r ssid sig sec inuse; do
      b=${bars[$(( sig >= 80 ? 4 : sig >= 60 ? 3 : sig >= 40 ? 2 : sig >= 20 ? 1 : 0 ))]}
      lock=""; { [ -n "$sec" ] && [ "$sec" != "--" ]; } && lock="󰌾"
      mark="  "; [ "$inuse" = 1 ] && mark="\u2713 "
      [ "$inuse" = 1 ] && sel=${#rows[@]}; [ "$sel" = 0 ] && sel=2   # open on the connected network (else the first), never on "turn off"
      rows+=("$(printf '%b' "$mark")$b  $(esc "$ssid")  $lock"); acts+=("net:$ssid:$sec")
    done < <(list_networks)
  else rows+=("󰖩  Turn Wi-Fi on"); acts+=("on")
  fi
  rows+=("󰒓  Advanced settings"); acts+=("adv")

  choice=$(printf '%s\n' "${rows[@]}" | rofi -dmenu -i -no-custom -markup-rows -format i -selected-row "$sel" -theme "$popup_theme" -mesg "$mesg" "${popup_keys[@]}")
  [ $? -eq 0 ] || exit 0
  case ${acts[choice]} in
    off) nmcli radio wifi off ;;
    on)  nmcli radio wifi on; sleep 2 ;;
    scan) nmcli dev wifi rescan >/dev/null 2>&1; sleep 2 ;;
    adv) nm-connection-editor >/dev/null 2>&1 & exit 0 ;;
    net:*) rest=${acts[choice]#net:}; ssid=${rest%:*}; sec=${rest##*:}
           if nmcli -t --escape no -f ACTIVE,SSID dev wifi | grep -Fxq "yes:$ssid"; then nmcli con down id "$ssid" >/dev/null 2>&1 && notify "Disconnected" "$ssid"
           else connect "$ssid" "$sec"; fi
           sleep 1 ;;
  esac
done

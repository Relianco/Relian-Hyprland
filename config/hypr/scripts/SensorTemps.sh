#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# CPU / GPU / drive temperatures for a Waybar custom module (return-type json).
# Looks sensors up by hwmon *name* (the hwmonN numbers change between boots). Missing sensors are skipped.
#   CPU: k10temp (AMD) or coretemp (Intel)   GPU: amdgpu, or nvidia-smi   Drives: every nvme
# class: ok < 70, warm >= 70, hot >= 85 (highest of anything shown)

CPU=$'\U000f0ee0'; GPU=$'\U000f08ae'; SSD=$'\U000f02ca'

read_temp() { # read_temp <hwmon dir> -> degrees C (integer) on stdout
  local v; v=$(cat "$1/temp1_input" 2>/dev/null) || return 1
  echo $(( v / 1000 ))
}
find_hwmon() { # find_hwmon <name> -> every hwmon dir with that name
  local d; for d in /sys/class/hwmon/hwmon*; do [ "$(cat "$d/name" 2>/dev/null)" = "$1" ] && echo "$d"; done
}

text=(); tip=(); max=0
add() { # add <glyph> <label> <temp>
  text+=("$1 $3°"); tip+=("$2: $3°C"); [ "$3" -gt "$max" ] && max=$3
}

for n in k10temp coretemp; do d=$(find_hwmon "$n" | head -1); [ -n "$d" ] && t=$(read_temp "$d") && { add "$CPU" "CPU ($n)" "$t"; break; }; done

d=$(find_hwmon amdgpu | head -1)
if [ -n "$d" ] && t=$(read_temp "$d"); then add "$GPU" "GPU (amdgpu)" "$t"
elif command -v nvidia-smi >/dev/null && t=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | head -1) && [ -n "$t" ]; then add "$GPU" "GPU (nvidia)" "$t"; fi

drives=(); i=0
while IFS= read -r d; do
  [ -n "$d" ] || continue
  t=$(read_temp "$d") || continue
  m=$(tr -s " " < "$d/device/model" 2>/dev/null | sed "s/ *$//"); i=$((i + 1))
  drives+=("$t"); tip+=("Drive $i${m:+ ($m)}: $t°C"); [ "$t" -gt "$max" ] && max=$t
done < <(find_hwmon nvme)
[ "${#drives[@]}" -gt 0 ] && text+=("$SSD $(IFS=/; echo "${drives[*]}")°")

class=ok; [ "$max" -ge 70 ] && class=warm; [ "$max" -ge 85 ] && class=hot
[ "${#text[@]}" -gt 0 ] || { printf '{"text":"","class":"hidden"}\n'; exit 0; }
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "${text[*]}" "$(printf '%s\\n' "${tip[@]}" | sed 's/\\n$//')" "$class"

#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Month calendar in the rofi look (right-click the clock in Waybar).
#   Left/Up previous month   Right/Down next month   Home or the "Today" row: back to this month   Esc: close
#   Calendar.sh [YYYY-MM]    open on a given month
# Colours come from the current theme (rofi's wallust colours). Events from Outlook/Gmail are planned: the rows under the
# month are where they will go (see events_for below).
rofi_theme="$HOME/.config/rofi/config-calendar.rasi"
colors="$HOME/.config/rofi/wallust/colors-rofi.rasi"

color() { sed -n "s/^$1: *\(#[0-9A-Fa-f]\{6\}\).*/\1/p" "$colors" 2>/dev/null | head -1; }
accent=$(color active-background); accent_fg=$(color active-foreground)
fg=$(color normal-foreground)
: "${accent:=#89B4FA}" "${accent_fg:=#000000}" "${fg:=#CDD6F4}"

# month_markup YEAR MONTH -> pango markup (Monday first, with ISO week numbers like the bar clock)
month_markup() {
  python3 - "$1" "$2" "$accent" "$accent_fg" "$fg" <<'PY'
import calendar, datetime, sys
y, m, accent, accent_fg, fg = int(sys.argv[1]), int(sys.argv[2]), *sys.argv[3:6]
today = datetime.date.today()
cal = calendar.Calendar(firstweekday=0)
name = datetime.date(y, m, 1).strftime("%B %Y")
out = [f'<span size="large" weight="bold" foreground="{accent}">{name:^26}</span>', "",
       '<span alpha="45%">Wk  Mo  Tu  We  Th  Fr  Sa  Su</span>']
for week in cal.monthdatescalendar(y, m):
    cells = []
    for d in week:
        s = f"{d.day:>2}"
        if d.month != m:   s = f'<span alpha="25%">{s}</span>'
        elif d == today:   s = f'<span background="{accent}" foreground="{accent_fg}" weight="bold"> {d.day:>2} </span>'
        elif d.weekday() >= 5: s = f'<span alpha="60%">{s}</span>'
        cells.append(s if d != today or d.month != m else s)
    # a highlighted day brings its own padding, so plain days get the same 2+2 spacing
    row = "".join(c if "background=" in c else f"  {c}" if i else f" {c}" for i, c in enumerate(cells))
    out.append(f'<span alpha="45%">{week[0].isocalendar()[1]:>2}</span>' + " " + row)
print("\n".join(out))
PY
}

# events_for YEAR MONTH -> lines "DD<TAB>text" (nothing yet: Outlook/Gmail sync is a later step)
events_for() { :; }

ym=${1:-$(date +%Y-%m)}
year=${ym%-*}; month=$((10#${ym#*-}))
today_label="Today  $(date '+%A %-d %B')"
while true; do
  markup=$(month_markup "$year" "$month")
  choice=$(printf '%s\n' "$today_label" | rofi -dmenu -i -no-custom -format i -theme "$rofi_theme" -mesg "$markup" \
    -kb-move-char-back "Control+b" -kb-move-char-forward "Control+f" -kb-row-up "Control+p" -kb-row-down "Control+n" \
    -kb-page-prev "" -kb-page-next "" -kb-row-first "" \
    -kb-custom-1 "Left,Up,Prior" -kb-custom-2 "Right,Down,Next" -kb-custom-3 "Home")
  case $? in
    10) month=$((month - 1)); [ "$month" -lt 1 ] && { month=12; year=$((year - 1)); } ;;
    11) month=$((month + 1)); [ "$month" -gt 12 ] && { month=1; year=$((year + 1)); } ;;
    12|0) year=$(date +%Y); month=$((10#$(date +%m))) ;;
    *) exit 0 ;;
  esac
done

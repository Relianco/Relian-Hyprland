#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# One Waybar icon for AI-coding-agent usage (like Omarchy's agents icon): shows the fullest limit,
# hover lists every limit of Claude Code and Codex with a meter and the time until it resets.
# Data comes from `claudebar --json` and `codexbar --json` (github.com/mryll/claudebar, mryll/codexbar,
# MIT; AUR: yay -S claudebar codexbar). Missing tools are listed in the tooltip, never an error.
# Output: Waybar JSON  {text, tooltip, class}  class = low|mid|high|critical|error|missing

ICON=$'\U000f06a9'
fetch() { command -v "$1" >/dev/null 2>&1 || { echo null; return; }
  local out; out=$(timeout 25 "$1" --json 2>/dev/null)
  jq -e . >/dev/null 2>&1 <<<"$out" && echo "$out" || echo '{"error":{"message":"no output"}}'; }

claude=$(fetch claudebar); codex=$(fetch codexbar)

jq -nc --argjson claude "$claude" --argjson codex "$codex" --arg icon "$ICON" '
  def esc: gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;");
  def dim($s): "<span alpha=\"55%\">" + $s + "</span>";
  def col($p): if $p >= 85 then "#e06c5a" elif $p >= 60 then "#e0a85a" else "#8fbf7a" end;
  def meter($p; $w): ([($p / 100 * $w) | round, $w] | min | [., 0] | max) as $f
                     | "<span foreground=\"\(col($p))\">" + ([range($f)] | map("█") | join("")) + "</span>"
                     + "<span alpha=\"25%\">" + ([range($w - $f)] | map("█") | join("")) + "</span>";
  def eta($u): ($u - now) as $s
               | if $s <= 0 then "now" elif $s < 3600 then "\($s / 60 | floor)m"
                 elif $s < 86400 then "\($s / 3600 | floor)h \(($s % 3600) / 60 | floor)m"
                 else "\($s / 86400 | floor)d \(($s % 86400) / 3600 | floor)h" end;
  def pad($s; $n): ($s + (" " * $n))[0:$n];
  def gap: "\n<span size=\"small\"> </span>\n";
  def row: "  \(pad(.label; 14) | esc)  \(meter(.used_pct; 22))  "
           + "<span weight=\"bold\" foreground=\"\(col(.used_pct))\">\(("   " + (.used_pct | round | tostring) + "%")[-4:])</span>   "
           + dim("resets in " + eta(.reset_at_unix));
  def section($name; $doc; $install):
    "<span size=\"large\" weight=\"bold\">\($name)</span>"
    + (if $doc == null then "   " + dim("not installed") + gap + "  " + dim($install)
       elif ($doc.error // null) != null then gap + "  <span foreground=\"#e06c5a\">\(($doc.error.message // "error") | esc)</span>"
       else (if ($doc.plan // "") != "" then "   " + dim($doc.plan | esc) else "" end)
            + (if $doc.stale == true then "   " + dim("stale") else "" end)
            + gap + ([($doc.windows // [])[] | row] | join(gap))
       end);
  def worst($docs): ($docs | map(select(. != null and (.error // null) == null) | .state))
                    | (map({low:0, mid:1, high:2, critical:3}[.] // 0) | max) as $w
                    | if $w == null then null else ["low","mid","high","critical"][$w] end;
  [$claude, $codex] as $docs
  | ($docs | map(select(. != null and (.error // null) == null) | (.max_pct // 0)) | max) as $pct
  | (worst($docs)) as $state
  | {text: (if $pct == null then $icon else "\($icon) \($pct | round)%" end),
     tooltip: ("<span size=\"small\" weight=\"bold\" alpha=\"55%\">AI AGENTS</span>" + gap
               + section("Claude Code"; $claude; "yay -S claudebar") + gap + gap
               + section("Codex"; $codex; "yay -S codexbar") + gap + gap
               + dim("click  ask an agent    right  Claude    middle  Codex")),
     class: (if $state != null then $state elif ($docs | all(. == null)) then "missing" else "error" end)}'

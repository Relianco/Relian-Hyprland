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
  def bar($p): ([($p / 10 | floor), 10] | min | [., 0] | max) as $f
               | ([range($f)] | map("█") | join("")) + ([range(10 - $f)] | map("░") | join(""));
  def eta($u): ($u - now) as $s
               | if $s <= 0 then "now" elif $s < 3600 then "\($s / 60 | floor)m"
                 elif $s < 86400 then "\($s / 3600 | floor)h \(($s % 3600) / 60 | floor)m"
                 else "\($s / 86400 | floor)d \(($s % 86400) / 3600 | floor)h" end;
  def pad($s; $n): ($s + (" " * $n))[0:$n];
  def section($name; $doc; $install):
    if $doc == null then "\($name)\n  not installed  (\($install))"
    elif ($doc.error // null) != null then "\($name)\n  \(($doc.error.message // "error") | esc)"
    else "\($name)" + (if ($doc.plan // "") != "" then "  (\($doc.plan | esc))" else "" end)
         + (if $doc.stale == true then "  [stale]" else "" end)
         + ([($doc.windows // [])[] | "\n  \(pad(.label; 14) | esc) \(bar(.used_pct)) \(.used_pct | round)%  resets in \(eta(.reset_at_unix))"] | join(""))
    end;
  def worst($docs): ($docs | map(select(. != null and (.error // null) == null) | .state) )
                    | (map({low:0, mid:1, high:2, critical:3}[.] // 0) | max) as $w
                    | if $w == null then null else ["low","mid","high","critical"][$w] end;
  [$claude, $codex] as $docs
  | ($docs | map(select(. != null and (.error // null) == null) | (.max_pct // 0)) | max) as $pct
  | (worst($docs)) as $state
  | {text: (if $pct == null then $icon else "\($icon) \($pct | round)%" end),
     tooltip: ([section("Claude Code"; $claude; "yay -S claudebar"), section("Codex"; $codex; "yay -S codexbar")] | join("\n\n")
               + "\n\nclick: ask an agent   right: Claude   middle: Codex"),
     class: (if $state != null then $state elif ($docs | all(. == null)) then "missing" else "error" end)}'

#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */  ##
# Ask a coding agent something from anywhere (like Omarchy's `agent prompt`).
#   AgentPrompt.sh              rofi box: type a prompt, ENTER -> Claude Code, SHIFT+ENTER -> Codex
#   AgentPrompt.sh claude|codex [prompt...]   open that agent now (empty prompt = interactive session)
# Opens a floating terminal (window class "agent", sized by a rule in WindowRules.lua) in $AGENT_DIR or $HOME.

rofi_theme="$HOME/.config/rofi/config-omarchy-launcher.rasi"
dir=${AGENT_DIR:-$HOME}

launch() { # launch <claude|codex> [prompt...]
  local agent=$1; shift
  command -v "$agent" >/dev/null 2>&1 || { notify-send -u normal "$agent is not installed" "Install it first (npm i -g @anthropic-ai/claude-code / npm i -g @openai/codex)"; exit 1; }
  local prompt="$*"
  if [ -n "$prompt" ]; then kitty --class agent --title "$agent" -d "$dir" "$agent" "$prompt" &
  else kitty --class agent --title "$agent" -d "$dir" "$agent" &
  fi
}

case "${1:-}" in
  claude|codex) agent=$1; shift; launch "$agent" "$@"; exit 0 ;;
esac

pkill rofi 2>/dev/null
text=$(printf '' | rofi -dmenu -theme "$rofi_theme" \
  -theme-str 'window { width: 640px; } entry { placeholder: "󰚩  Ask an agent..."; } listview { lines: 0; }' \
  -mesg "Enter: Claude Code    Shift+Enter: Codex    Esc: cancel" \
  -kb-accept-alt "" -kb-custom-1 "Shift+Return")   # Shift+Return is rofi's own accept-alt, so free it first
rc=$?
case $rc in
  0)  launch claude "$text" ;;
  10) launch codex "$text" ;;
  *)  exit 0 ;;
esac

#!/usr/bin/env bash
# /* ---- Relian-Hyprland ---- */
# Preview the login theme in SDDM's own test greeter: a normal window, no root, nothing is installed or changed.
#   tools/preview-login.sh ["Theme name"]      (close the window with Esc/Alt+F4)
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
args=(); [ -n "${1:-}" ] && args=(--theme "$1")
python3 "$root/tools/build-sddm-theme.py" "$tmp/relian" "${args[@]}" || exit 1
exec sddm-greeter-qt6 --test-mode --theme "$tmp/relian"

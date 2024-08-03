#!/usr/bin/env bash

current_session=$(tmux display-message -p '#{session_name}')
current_window_index=$(tmux display-message -p '#{window_index}')
current_window_name=$(tmux display-message -p '#{window_name}')


CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

current_window_origin=$(tmux display-message -p '#S:#I: #{window_name}')
current_window=$(tmux display-message -p '#S:#I:')


if [[ -z  "$TMUX_FZF_WINDOW_FILTER" ]]; then
  window_filter="-a"
else
  window_filter="-f \"$TMUX_FZF_WINDOW_FILTER\""
fi

if [[ -z "$TMUX_FZF_WINDOW_FORMAT" ]]; then
    windows=$(tmux list-windows $window_filter)
else
    windows=$(tmux list-windows $window_filter -F "#S:#{window_index}: $TMUX_FZF_WINDOW_FORMAT")
fi

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target window.'"
if [[ -z "$TMUX_FZF_SWITCH_CURRENT" ]]; then
    windows=$(echo "$windows" | grep -v "^$current_window")
fi
target_origin=$(printf "%s\n[cancel]" "$windows" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
[[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
target=$(echo "$target_origin" | sed 's/: .*//')
echo "$target" | sed 's/:.*//g' | xargs -I{} tmux switch-client -t {}
echo "$target" | xargs -I{} tmux select-window -t {}


new_session=$(tmux display-message -p '#{session_name}')
new_window=$(tmux display-message -p '#{window_index}')

if [ "$current_session" = "$new_session" ] && [ "$current_window_index" = "$new_window" ]; then
    return
fi

# echo "current": $current_session:$current_window:$current_window_name

tmp_file="/tmp/tmux_previous"

echo -e "$current_session\n$current_window_index" > "$tmp_file"

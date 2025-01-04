#!/bin/bash

# tmux 跳转到前一个window，不区分session

current_session=$(tmux display-message -p '#{session_name}')
current_window=$(tmux display-message -p '#{window_index}')
current_window_name=$(tmux display-message -p '#{window_name}')

tmp_file="/tmp/tmux_previous"

if [ -f "$tmp_file" ]; then
    IFS=$'\n' read -d '' -r -a previous_values <"$tmp_file"
    previous_session="${previous_values[0]}"
    previous_window="${previous_values[1]}"
else
    previous_session=""
    previous_window=""
fi

if [ -z "$previous_session" ] || [ -z "$previous_window" ]; then
    echo -e "$current_session\n$current_window" >"$tmp_file"
    echo "first init"
    echo "previous: $previous_session:$previous_window"
    echo "current: $current_session:$current_window"
    exit
fi

# echo $previous_session
# echo $previous_window

if [ "$current_session" = "$previous_session" ] && [ "$current_window" = "$previous_window" ]; then
    echo "Current and previous windows are the same. Doing nothing."
    exit
fi

tmux switch-client -t "${previous_session}:${previous_window}"

# echo "current: $current_session:$current_window:$current_window_name"

echo -e "$current_session\n$current_window" >"$tmp_file"

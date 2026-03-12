#!/bin/bash

# tmux 跳转到前一个window，不区分session

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_HISTORY_SCRIPT="$CURRENT_DIR/update_history.sh"

current_session=$(tmux display-message -p '#{session_name}')
current_window=$(tmux display-message -p '#{window_index}')

tmp_file="/tmp/tmux_previous"
lock_dir="${tmp_file}.lock"

write_state() {
    local tmp_write_file="${tmp_file}.$$"
    printf "%s\n%s\n" "$1" "$2" >"$tmp_write_file"
    mv "$tmp_write_file" "$tmp_file"
}

cleanup() {
    rmdir "$lock_dir" 2>/dev/null || true
}

if ! mkdir "$lock_dir" 2>/dev/null; then
    exit 0
fi

trap cleanup EXIT

if [ -f "$tmp_file" ]; then
    IFS=$'\n' read -d '' -r -a previous_values <"$tmp_file"
    previous_session="${previous_values[0]}"
    previous_window="${previous_values[1]}"
else
    previous_session=""
    previous_window=""
fi

if [ -z "$previous_session" ] || [ -z "$previous_window" ]; then
    write_state "$current_session" "$current_window"
    exit 0
fi

if [ "$current_session" = "$previous_session" ] && [ "$current_window" = "$previous_window" ]; then
    exit 0
fi

tmux switch-client -t "${previous_session}:${previous_window}"

bash "$UPDATE_HISTORY_SCRIPT" "${previous_session}:${previous_window}"

write_state "$current_session" "$current_window"

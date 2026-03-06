#!/bin/bash

target_line="$1"
target="${target_line%%: *}"

pane=$(
    tmux list-panes -t "$target" -F "#{pane_id} #{pane_active}" 2>/dev/null |
        awk '$2 == 1 { print $1; exit }'
)

[ -n "$pane" ] || exit 0

preview_lines="${FZF_PREVIEW_LINES:-50}"

content=$(tmux capture-pane -e -N -p -t "$pane" 2>/dev/null) || exit 0

printf "%s\n" "$content" |
    awk '
        { lines[++count] = $0 }
        NF { last_non_empty = count }
        END {
            if (!last_non_empty) {
                exit
            }

            start = 1
            if (start < 1) {
                start = 1
            }

            for (i = start; i <= last_non_empty; i++) {
                print lines[i]
            }
        }
    ' |
    tail -n "$preview_lines"

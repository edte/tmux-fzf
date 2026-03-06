#!/bin/bash

target="$1"
[ -n "$target" ] || exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-fzf"
stats_file="$state_dir/window_stats.tsv"
events_file="$state_dir/window_events.tsv"
tmp_file="$stats_file.tmp.$$"

mkdir -p "$state_dir"

now=$(date +%s)

printf "%s\t%s\n" "$target" "$now" >>"$events_file"

if [ ! -f "$stats_file" ]; then
    printf "%s\t%s\t1\n" "$target" "$now" >"$stats_file"
    exit 0
fi

awk -F '\t' -v OFS='\t' -v target="$target" -v now="$now" '
    BEGIN {
        found = 0
    }
    $1 == target {
        count = ($3 == "" ? 0 : $3) + 1
        print target, now, count
        found = 1
        next
    }
    NF {
        print
    }
    END {
        if (!found) {
            print target, now, 1
        }
    }
' "$stats_file" >"$tmp_file" && mv "$tmp_file" "$stats_file"

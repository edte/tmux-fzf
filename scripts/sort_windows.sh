#!/bin/bash

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-fzf"
stats_file="$state_dir/window_stats.tsv"
events_file="$state_dir/window_events.tsv"
now=$(date +%s)

if [ ! -f "$events_file" ] && [ ! -f "$stats_file" ]; then
    cat
    exit 0
fi

awk -F '\t' -v OFS='\t' -v stats_file="$stats_file" -v events_file="$events_file" -v now="$now" '
    BEGIN {
        if ((getline < events_file) >= 0) {
            close(events_file)
            while ((getline < events_file) > 0) {
                target = $1
                ts = $2 + 0
                age = now - ts

                if (age <= 3600) {
                    weight = 16
                } else if (age <= 86400) {
                    weight = 8
                } else if (age <= 604800) {
                    weight = 4
                } else if (age <= 2592000) {
                    weight = 2
                } else {
                    weight = 1
                }

                score[target] += weight

                if (ts > last[target]) {
                    last[target] = ts
                }

                count[target] += 1
            }
            close(events_file)
        } else if ((getline < stats_file) >= 0) {
            close(stats_file)
            while ((getline < stats_file) > 0) {
                last[$1] = $2 + 0
                count[$1] = $3 + 0
                score[$1] = count[$1]
            }
            close(stats_file)
        }
    }
    {
        line = $0
        key = line
        sub(/: .*/, "", key)
        printf "%012d\t%012d\t%012d\t%s\n", score[key], last[key], count[key], line
    }
' | sort -t $'\t' -k1,1nr -k2,2nr -k3,3nr -k4,4 | cut -f4-

#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $CURRENT_DIR
bind-key -n "c-l" run-shell -b  "$CURRENT_DIR/scripts/switch_window.sh\n"
bind-key -n "c-h" run-shell -b  "$CURRENT_DIR/scripts/last_window.sh.sh\n"

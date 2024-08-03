#!/usr/bin/env bash

current_session=$(tmux display-message -p '#{session_name}')
current_window_index=$(tmux display-message -p '#{window_index}')
current_window_name=$(tmux display-message -p '#{window_name}')


CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/.envs"

current_window_origin=$(tmux display-message -p '#S:#I: #{window_name}')
current_window=$(tmux display-message -p '#S:#I:')


windows=$(tmux list-windows -a -F "#S:#{window_index}: #{window_name}" | grep -v "^$current_window" )

# $TMUX_FZF_BIN 是 fzf 可执行文件的路径，$TMUX_FZF_OPTIONS 和 $TMUX_FZF_PREVIEW_OPTIONS 是传递给 fzf 的选项。
# fzf 是一个命令行模糊查找器，用于在列表中选择一个项目。最后，用户选择的项目（窗口）存储在 target_origin 变量中。
select_window=$(printf  "$windows" | eval "$TMUX_FZF_BIN -p -w 90% -h 90% -m --preview='/Users/edte/go/src/test/tmux-fzf/scripts/.preview {}' --preview-window=:follow")
[[  -z "$select_window" ]] && exit

# 这行代码使用 sed 命令删除 target_origin 中的 : 之后的所有内容，只保留窗口的索引或名称。处理后的结果存储在 target 变量中。
target=$(echo "$select_window" | sed 's/: .*//')

# 这行代码首先使用 sed 命令删除 target 中的 : 之后的所有内容（如果存在）。
# 然后，它使用 xargs 命令将处理后的 target 传递给 tmux switch-client -t 命令，从而切换到目标窗口所在的会话。
echo "$target" | sed 's/:.*//g' | xargs -I{} tmux switch-client -t {}

# 这行代码使用 xargs 命令将 target 变量传递给 tmux select-window -t 命令，从而激活并切换到目标窗口。
echo "$target" | xargs -I{} tmux select-window -t {}


new_session=$(tmux display-message -p '#{session_name}')
new_window=$(tmux display-message -p '#{window_index}')

if [ "$current_session" = "$new_session" ] && [ "$current_window_index" = "$new_window" ]; then
    return
fi

# echo "current": $current_session:$current_window:$current_window_name

tmp_file="/tmp/tmux_previous"

echo -e "$current_session\n$current_window_index" > "$tmp_file"

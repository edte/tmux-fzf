# tmux-fzf

A small tmux plugin for switching windows across sessions with `fzf-tmux`.

## Features

- `Ctrl-l`: open a window picker across all tmux sessions
- `Ctrl-h`: jump back to the previous window
- Preview the current active pane on the right side
- Keep ANSI colors in preview output
- Use exact search instead of fuzzy search

## Requirements

- `tmux`
- `fzf-tmux`

Check `fzf-tmux`:

```bash
which fzf-tmux
```

## Install

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'edte/tmux-fzf'
```

Then reload tmux config and install plugins:

```bash
tmux source-file ~/.tmux.conf
```

Inside tmux:

```bash
prefix + I
```

## Key Bindings

```text
Ctrl-l  Open window picker
Ctrl-h  Jump to previous window
```

## Search Behavior

The picker uses `fzf --exact`.

That means:

- input must appear as a continuous substring
- it does not use fuzzy matching
- match highlight color is `#FF4500`

Examples:

- `manage` matches `push-manage-console`
- `mnge` does not match `push-manage-console`

## Preview Behavior

The right preview window shows the current visible content of the target window's active pane.

Current behavior:

- only previews the active pane
- only captures visible pane content
- trims trailing blank lines
- keeps ANSI colors
- preview background is styled separately from the left list

## How It Works

```mermaid
flowchart LR
    A[Ctrl-l] --> B[list all tmux windows]
    B --> C[fzf-tmux picker]
    C --> D[right preview]
    D --> E[capture active pane]
    C --> F[select target window]
    F --> G[switch client to target session]
    G --> H[select target window]
```

## Files

- `main.tmux`: register key bindings
- `scripts/switch_window.sh`: open picker and switch window
- `scripts/preview_pane.sh`: render preview content
- `scripts/last_window.sh`: jump back to previous window

## Notes

- The previous window state is stored in `/tmp/tmux_previous`
- Preview quality depends on how tmux captures pane content from terminal apps

## Reference

- https://github.com/sainnhe/tmux-fzf
- https://github.com/Kristijan/fzf-pane-switch.tmux

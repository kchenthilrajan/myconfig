# Tmux Shortcuts

Prefix key: `Ctrl+b` (press before every shortcut)

---

## Sessions

| Action                        | Command                              |
|-------------------------------|--------------------------------------|
| New session                   | `tmux new -s <name>`                 |
| List sessions                 | `tmux ls`                            |
| Attach to session             | `tmux attach -t <name>`              |
| Detach from session           | `Ctrl+b d`                           |
| Kill a session                | `tmux kill-session -t <name>`        |
| Switch to next session        | `Ctrl+b )`                           |
| Switch to previous session    | `Ctrl+b (`                           |
| Rename current session        | `Ctrl+b $`                           |

---

## Windows (Tabs)

| Action                        | Shortcut          |
|-------------------------------|-------------------|
| New window                    | `Ctrl+b c`        |
| Next window                   | `Ctrl+b n`        |
| Previous window               | `Ctrl+b p`        |
| Switch to window by number    | `Ctrl+b <0-9>`    |
| Rename current window         | `Ctrl+b ,`        |
| List all windows              | `Ctrl+b w`        |
| Close current window          | `Ctrl+b &`        |

---

## Panes (Splits)

| Action                        | Shortcut          |
|-------------------------------|-------------------|
| Split horizontally            | `Ctrl+b "`        |
| Split vertically              | `Ctrl+b %`        |
| Switch between panes          | `Ctrl+b <arrow>`  |
| Close current pane            | `Ctrl+b x`        |
| Zoom/unzoom pane              | `Ctrl+b z`        |
| Show pane numbers             | `Ctrl+b q`        |
| Move pane to new window       | `Ctrl+b !`        |
| Resize pane                   | `Ctrl+b Ctrl+<arrow>` |
| Swap pane with previous       | `Ctrl+b {`        |
| Swap pane with next           | `Ctrl+b }`        |

---

## Copy Mode (Scroll)

| Action                        | Shortcut          |
|-------------------------------|-------------------|
| Enter copy mode (scroll up)   | `Ctrl+b [`        |
| Enter copy mode + search      | `Ctrl+b /`        |
| Exit copy mode                | `q`               |
| Search forward                | `/`               |
| Search backward               | `?`               |
| Next match                    | `n`               |
| Previous match                | `N`               |
| Begin selection (vi)          | `v`               |
| Rectangle selection           | `Ctrl+v`          |
| Copy selection                | `y`               |
| Paste buffer                  | `Ctrl+b ]`        |
| Page up                       | `Ctrl+u`          |
| Page down                     | `Ctrl+d`          |

---

## Pane Navigation (custom)

| Action                        | Shortcut          |
|-------------------------------|-------------------|
| Navigate panes (vim-style)    | `Ctrl+b h/j/k/l`  |
| Navigate panes (arrows)       | `Ctrl+b ←/↓/↑/→`  |

---

## Plugins

| Action                        | Shortcut          |
|-------------------------------|-------------------|
| Clear scrollback history      | `Ctrl+b K`        |
| Open file from pane in nvim   | `Ctrl+b F`        |
| Open file from pane history   | `Ctrl+b H`        |
| Open file from all panes      | `Ctrl+b G`        |
| Pomodoro start/pause          | `Ctrl+b p`        |
| Pomodoro cancel               | `Ctrl+b P`        |
| Pomodoro menu                 | `Ctrl+b Ctrl+p`   |
| Session tree (sorted)         | `Ctrl+b s`        |

---

## Misc

| Action                        | Shortcut / Command          |
|-------------------------------|-----------------------------|
| Show key bindings             | `Ctrl+b ?`                  |
| Reload tmux config            | `tmux source ~/.tmux.conf`  |
| Command prompt                | `Ctrl+b :`                  |
| Show clock                    | `Ctrl+b t`                  |
| Install plugins (tpm)         | `Ctrl+b I`                  |
| Update plugins (tpm)          | `Ctrl+b U`                  |

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for macOS — Neovim, tmux, Zsh, and iTerm2. All configs are symlinked from here to their expected locations. Changes here take effect via symlinks immediately (no deploy step needed), except nvim which requires restarting nvim or `:source`.

## Symlink layout

| File in repo | Symlinked to |
|---|---|
| `nvim/` | `~/.config/nvim` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/p10k.zsh` | `~/.p10k.zsh` |
| `zsh/omz-custom/` | `~/.oh-my-zsh/custom` |
| `w3m/keymap` | `~/.w3m/keymap` |

## Applying changes

- **zshrc**: `source ~/.zshrc`
- **tmux.conf**: `tmux source ~/.tmux.conf`
- **nvim**: restart nvim (or `:Lazy reload` for plugin changes)
- **Brewfile**: `brew bundle install --file=~/myconfig/Brewfile`

## Neovim architecture

Built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) using `lazy.nvim`.

- `nvim/init.lua` — main config: options, keymaps, plugin declarations
- `nvim/lua/custom/keymaps.lua` — custom keymaps, autocmds, session restore, todo highlights
- `nvim/lua/custom/plugins/init.lua` — custom plugins (bufferline, lualine, neo-tree, snacks, diffview, etc.)
- `nvim/lua/kickstart/plugins/` — kickstart-provided plugins (telescope, gitsigns, lint, autopairs, etc.)

Key plugins: telescope (file/grep search), neo-tree (file explorer, opens on right), bufferline, snacks.nvim (floating terminal via `<leader>t` / `<C-t>`), nvim-ufo (folding), persistence.nvim (session restore), supermaven (AI completion), catppuccin theme.

On `VimEnter` with no args: restores previous session via persistence.nvim and opens neo-tree automatically.

## Zsh custom functions (in zshrc)

- **`fz <file>` or `cmd | fz`** — fuzzy search any file or piped input with a right-side preview pane (±15 lines context)
- **`ref`** — unified fuzzy search across all shortcut reference files at `~/backup/`, color-coded by source
- **`_ref_file <file>`** — underlying helper used by per-topic aliases
- **`iterm-alpha <0-1>`** — set iTerm2 transparency via osascript

Per-topic shortcut aliases: `nvim-keys`, `tmux-keys`, `shell-cmds`, `shell-ex`, `docker-keys` — each opens the relevant `~/backup/*-shortcuts.md` in fzf with preview.

## Reference shortcut files

Stored at `~/backup/` (not in this repo — personal machine only):

| File | Content |
|---|---|
| `nvim-shortcuts.md` | Neovim keybindings |
| `tmux-shortcuts.md` | tmux keybindings |
| `shell-commands.md` | Shell/grep/awk/sed commands |
| `docker-shortcuts.md` | Docker + Colima commands |
| `commands_consolidated.md` | Consolidated reference |
| `cli_navigate_keyboard_shortcuts` | CLI navigation shortcuts |

## tmux setup

- Sessions are prefix-numbered for sort order (e.g. `1-FMC`, `2-agentic-backend`) — tmux sorts alphabetically in `Ctrl+b s`
- `Ctrl+b s` uses `choose-tree -sZ -O name` (sorted by name)
- Plugin manager: tpm. Plugins: catppuccin theme, tmux-yank, tmux-resurrect, tmux-continuum (auto-restore on)
- Pane navigation: `Ctrl+b` + arrow keys or vim-style `h/j/k/l`

## iTerm2

- `transparent` / `opaque` aliases control window transparency
- Password Manager: `Window > Password Manager`, can be triggered on password prompts via `Settings > Profiles > Advanced > Triggers`
- Terminal type is `xterm-256color` — ncurses apps inside tmux need `TERM=xterm-256color`

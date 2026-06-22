# Neovim Shortcuts

## Buffer Navigation (bufferline)
| Key                 | Action                        |
|---------------------|-------------------------------|
| `Shift+h`           | Previous buffer               |
| `Shift+l`           | Next buffer                   |
| `<leader>1`–`9`     | Jump to buffer by position    |
| `<leader>bd`        | Close current buffer          |
| `<leader>bp`        | Pin / unpin buffer            |
| `<leader>bx`        | Close all other buffers       |

## File Explorer (neo-tree)
| Key                  | Action                        |
|----------------------|-------------------------------|
| `<leader>e`          | Toggle neo-tree               |
| `Ctrl+w` then `h`    | Move focus away from neo-tree |
| `R`                  | Refresh neo-tree              |
| `/`                  | Filter files in current tree  |
| `Esc`                | Clear filter                  |

## File Search (telescope)
| Key                  | Action                              |
|----------------------|-------------------------------------|
| `<leader>sf`         | Search files by name                |
| `<leader>sg`         | Search inside files (live grep)     |
| `<leader>sw`         | Search current word                 |
| `<leader>sh`         | Search help tags                    |
| `<leader>sk`         | Search keymaps                      |
| `<leader>sd`         | Search diagnostics                  |
| `<leader>sr`         | Resume last search                  |
| `<leader>s.`         | Search recent files                 |
| `<leader>ss`         | Search telescope builtins           |
| `<leader>s/`         | Live grep in open files             |
| `<leader>sn`         | Search neovim config files          |
| `<leader><leader>`   | Find existing buffers               |
| `<leader>/`          | Fuzzy search in current buffer      |

### Inside Telescope overlay
| Key          | Action                                          |
|--------------|-------------------------------------------------|
| `Tab`        | Mark file (multi-select)                        |
| `Shift+Tab`  | Unmark file                                     |
| `Ctrl+o`     | Load all marked files as buffers (no splits)    |
| `Ctrl+d`     | Delete buffer (buffer list only)                |
| `Ctrl+t`     | Open file in new tab                            |
| `Ctrl+v`     | Open file in vertical split                     |
| `Ctrl+x`     | Open file in horizontal split                   |
| `Ctrl+q`     | Send all marked to quickfix list                |
| `Enter`      | Open highlighted file                           |
| `Esc`        | Close overlay                                   |

## Scrolling
| Key      | Action                    |
|----------|---------------------------|
| `Ctrl+e` | Scroll down one line      |
| `Ctrl+y` | Scroll up one line        |
| `Ctrl+d` | Scroll down half page     |
| `Ctrl+u` | Scroll up half page       |
| `Ctrl+f` | Scroll down full page     |
| `Ctrl+b` | Scroll up full page       |
| `gg`     | Jump to top of file       |
| `G`      | Jump to bottom of file    |

## Overlay trigger keys (which-key)
| Key      | What opens                                      |
|----------|-------------------------------------------------|
| `<leader>` | Search, toggles, diagnostics, formatting      |
| `Ctrl+w` | Window management (splits, focus, resize)       |
| `g`      | Go-to commands (gd, gr, gi, etc.)               |
| `z`      | Fold commands (zo, zc, zR, zM, etc.)            |
| `[` / `]`| Navigation (diagnostics, hunks, etc.)           |
| `"` `'`  | Registers / marks picker                        |
| `@`      | Macro run picker                                |

## Folding (nvim-ufo)
| Key   | Action                              |
|-------|-------------------------------------|
| `zo`  | Open fold under cursor              |
| `zc`  | Close fold under cursor             |
| `zR`  | Open all folds                      |
| `zM`  | Close all folds                     |
| `zK`  | Peek inside fold without opening    |

## LSP
| Key            | Action                          |
|----------------|---------------------------------|
| `grn`          | Rename symbol                   |
| `gra`          | Code action                     |
| `grr`          | Go to references                |
| `gri`          | Go to implementation            |
| `grd`          | Go to definition                |
| `grD`          | Go to declaration               |
| `gO`           | Document symbols                |
| `gW`           | Workspace symbols               |
| `grt`          | Go to type definition           |
| `<leader>th`   | Toggle inlay hints              |

## Formatting
| Key          | Action                        |
|--------------|-------------------------------|
| `<leader>f`  | Format buffer                 |

## Window Navigation
| Key      | Action                        |
|----------|-------------------------------|
| `Ctrl+h` | Move focus to left window     |
| `Ctrl+l` | Move focus to right window    |
| `Ctrl+j` | Move focus to lower window    |
| `Ctrl+k` | Move focus to upper window    |

## Diagnostics
| Key          | Action                        |
|--------------|-------------------------------|
| `<leader>q`  | Open diagnostic quickfix list |

## Git (gitsigns)
| Key            | Action                                  |
|----------------|-----------------------------------------|
| `<leader>hb`   | Blame current line (popup)              |
| `<leader>tb`   | Toggle inline blame on all lines        |
| `<leader>hd`   | Diff current file against index         |
| `<leader>hD`   | Diff against last commit                |
| `<leader>hp`   | Preview hunk                            |
| `<leader>hs`   | Stage hunk                              |
| `<leader>hr`   | Reset hunk                              |
| `<leader>hS`   | Stage entire buffer                     |
| `<leader>hR`   | Reset entire buffer                     |
| `<leader>hb`   | Blame current line (popup)              |
| `<leader>tb`   | Toggle inline blame on all lines        |
| `]c` / `[c`    | Jump to next/previous git change        |
| `:q`           | Close gitsigns diff view                |

## Diffview
| Key              | Action                                      |
|------------------|---------------------------------------------|
| `<leader>gd`     | Open diffview (all changed files)           |
| `<leader>gD`     | Close diffview                              |
| `<leader>gh`     | Git history for current file                |
| `<leader>gH`     | Full repo git history                       |
| `<tab>`          | Switch between changed files (left panel)   |
| `]x` / `[x`      | Jump to next/previous hunk                  |
| `do`             | Diff obtain — pull change from right into left |
| `dp`             | Diff put — push original back, discard change  |
| `u`              | Undo a `do` or `dp`                         |
| `:DiffviewClose` | Close diffview (also `<leader>gD`)          |

## Neo-tree (extra)
| Key            | Action                                  |
|----------------|-----------------------------------------|
| `<leader>e`            | Reveal current file in neo-tree (focus)      |
| `:Neotree reveal focus`| Reveal & focus current file (if already open)|
| `Y`                    | Copy filename to clipboard                   |
| `gy`                   | Copy full path to clipboard                  |

## iron.nvim (REPL — run code inline like SQL editor)
| Key              | Action                                              |
|------------------|-----------------------------------------------------|
| `<leader>io`     | Open REPL split (auto-detects filetype)             |
| `<leader>il`     | Send current line to REPL                           |
| `<leader>ic`     | Send motion/visual selection to REPL                |
| `<leader>iu`     | Send from top of file to cursor                     |
| `<leader>ia`     | Send entire file                                    |
| `<leader>i<cr>`  | Send Enter to REPL                                  |
| `<leader>i<space>` | Interrupt running command                         |
| `<leader>ix`     | Clear REPL output                                   |
| `<leader>iq`     | Quit REPL                                           |
| `<leader>ir`     | Restart REPL                                        |
| `<leader>if`     | Focus REPL window                                   |
| `<leader>ih`     | Hide REPL window                                    |

### Workflow
1. Open a `.sh`, `.py`, or `.js` file
2. `<leader>io` — opens REPL split on the right
3. Write commands, put cursor on a line → `<leader>il` to run it
4. Visual select multiple lines → `<leader>ic` to run the block
5. Output appears live in the REPL pane

## kulala.nvim (HTTP client — .http files)
| Key            | Action                                      |
|----------------|---------------------------------------------|
| `<leader>rr`   | Run request under cursor                    |
| `<leader>ra`   | Run all requests in file                    |
| `<leader>rn`   | Jump to next request                        |
| `<leader>rp`   | Jump to previous request                    |
| `<leader>rc`   | Copy request as curl command                |
| `<leader>ri`   | Inspect request (show resolved vars)        |
| `<leader>rf`   | Import curl from clipboard → .http format   |

### .http file format
```
### Request name
GET https://api.example.com/users
Authorization: Bearer {{TOKEN}}

### POST example
POST https://api.example.com/users
Content-Type: application/json

{
  "name": "chenthil"
}
```
- Separate requests with `###`
- Use `{{VAR}}` for variables from `.env` file in project root
- Works on `.http` or `.rest` files

## Snacks Terminal
| Key            | Action                                                        |
|----------------|---------------------------------------------------------------|
| `<leader>t`    | Toggle floating terminal (normal mode)                        |
| `<C-t>`        | Toggle floating terminal (from anywhere — normal or terminal) |
| `<Esc><Esc>`   | Exit terminal insert mode (without closing terminal)          |

## Command History
| Key                        | Action                                      |
|----------------------------|---------------------------------------------|
| `Ctrl+p` / `Up`            | Previous command in `:` prompt              |
| `Ctrl+n` / `Down`          | Next command in `:` prompt                  |
| `<leader>sc`               | Fuzzy search command history (Telescope)    |

## expand() — File Info Tokens
| Command | Returns |
|---|---|
| `:echo expand('%')` | Current filename |
| `:echo expand('%:p')` | Full absolute path |
| `:echo expand('%:h')` | Directory of current file |
| `:echo expand('%:t')` | Filename without directory |
| `:echo expand('%:e')` | File extension only |
| `:echo expand('%:r')` | Filename without extension |
| `:echo expand('%:~')` | Path relative to `~` |
| `:echo expand('%:.')` | Path relative to current dir |
| `:let @+ = expand('%:p')` | Copy full path to clipboard |

## Registers
| Register | What it holds |
|---|---|
| `@+` | System clipboard |
| `@"` | Default (last yank/delete) |
| `@0` | Last yanked text |
| `@1`-`@9` | Last 9 deletes (history) |
| `@a`-`@z` | Named registers (manual use) |
| `@/` | Last search pattern |
| `@:` | Last command executed |
| `@%` | Current filename |
| `@.` | Last inserted text |

### Using Registers
| Command | Action |
|---|---|
| `:let @a = expand('%:p')` | Save filepath to register `a` |
| `:echo @:` | Print last command |
| `Ctrl+r +` | Paste clipboard in insert/cmd mode |
| `Ctrl+r a` | Paste register `a` in insert/cmd mode |
| `Ctrl+r /` | Paste last search term |
| `Ctrl+r :` | Paste last command in cmd prompt |
| `"ap` | Paste register `a` in normal mode |
| `"+p` | Paste clipboard in normal mode |

## Commenting (mini.comment / Comment.nvim)
| Key              | Action                                          |
|------------------|-------------------------------------------------|
| `gcc`            | Toggle comment on current line                  |
| `gcip`           | Toggle comment on paragraph                     |
| `gc5j`           | Toggle comment on next 5 lines                  |
| `gc` (visual)    | Toggle comment on selected lines                |

## Search & Replace (Find and Replace)
| Command                  | Action                                              |
|--------------------------|-----------------------------------------------------|
| `:%s/old/new/g`          | Replace all occurrences in file                     |
| `:%s/old/new/gc`         | Replace all with confirmation (y/n/a/q per match)   |
| `:%s/old/new/gi`         | Replace all, case insensitive                       |
| `:10,20s/old/new/g`      | Replace only in lines 10–20                         |
| `:'<,'>s/old/new/g`      | Replace in visual selection (auto-filled with `:`)) |

## Favorite Commands & Quick Actions
| Key            | Action                                                  |
|----------------|---------------------------------------------------------|
| `<leader>oc`   | Open favorite commands palette (fuzzy pick + run)       |
| `<leader>yp`   | Copy full file path to clipboard                        |

## Misc
| Key              | Action                        |
|------------------|-------------------------------|
| `<Esc>`          | Clear search highlight        |
| `<Esc><Esc>`     | Exit terminal insert mode (see Snacks Terminal section for full terminal shortcuts) |

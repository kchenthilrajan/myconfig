# myconfig

Personal dotfiles for Neovim, tmux, Zsh (Oh My Zsh + Powerlevel10k), on macOS and Linux (Mint).

## Contents

| Path | Description |
|------|-------------|
| `nvim/` | Neovim config (lazy.nvim) |
| `tmux/tmux.conf` | tmux config |
| `zsh/zshrc` | Zsh config with Oh My Zsh |
| `zsh/p10k.zsh` | Powerlevel10k prompt config |
| `zsh/omz-custom/` | Oh My Zsh custom plugins/themes |
| `w3m/keymap` | w3m browser keybindings (`/`, `n`, `N` search) |
| `Brewfile` | Homebrew formulas shared by both OSes |
| `Brewfile.macos` | macOS-only casks (fonts, iTerm2, JDKs) — installed in addition to `Brewfile` on macOS only |

Linux gets a few things Homebrew casks can't provide (Docker Engine, zathura, Nerd Fonts, a JDK, LaTeX) via `apt` instead — see `setup.sh` and the **Linux (Mint) notes** section below.

## Quick Setup

On a brand new machine (macOS or Linux), one command does everything below automatically:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kchenthilrajan/myconfig/master/setup.sh)"
```

The rest of this section is the manual/reference version of what that script does.

## New Machine Setup

### 1. Clone

```bash
git clone --recurse-submodules https://github.com/kchenthilrajan/myconfig.git ~/myconfig
```

> `--recurse-submodules` pulls Powerlevel10k automatically.

### 2. Install Homebrew (if not present)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then add it to your shell (the installer prints this too):

```bash
# macOS
eval "$(/opt/homebrew/bin/brew shellenv)"
# Linux
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### 3. Install all tools and fonts

```bash
brew bundle install --file=~/myconfig/Brewfile
# macOS only — fonts, iTerm2, JDKs, zathura, colima+docker:
brew bundle install --file=~/myconfig/Brewfile.macos
```

This installs Neovim, tmux, fzf, bat, eza, fd, glow, and everything else in the Brewfile. On macOS, `Brewfile.macos` adds Nerd Fonts, iTerm2, and JDKs via casks; on Linux those instead come from `apt` (see `setup.sh`).

### 4. Install Oh My Zsh (if not present)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 5. Create symlinks

```bash
# Neovim
ln -sf ~/myconfig/nvim ~/.config/nvim

# tmux
ln -sf ~/myconfig/tmux/tmux.conf ~/.tmux.conf

# Zsh
ln -sf ~/myconfig/zsh/zshrc ~/.zshrc
ln -sf ~/myconfig/zsh/p10k.zsh ~/.p10k.zsh

# Oh My Zsh custom (plugins + themes including powerlevel10k)
ln -sf ~/myconfig/zsh/omz-custom ~/.oh-my-zsh/custom

# w3m keybindings
mkdir -p ~/.w3m
ln -sf ~/myconfig/w3m/keymap ~/.w3m/keymap
```

### 6. Set Zsh as default shell (if needed)

```bash
chsh -s $(which zsh)
```

### 7. Reload shell

```bash
source ~/.zshrc
```

Neovim plugins will auto-install via lazy.nvim on first launch.

## Linux (Mint) notes

- **Homebrew** installs to `/home/linuxbrew/.linuxbrew` instead of `/opt/homebrew`; `zshrc`'s PATH setup detects the OS and points at the right prefix automatically.
- **Casks don't exist on Linux.** Fonts (Nerd Fonts), iTerm2, Skim, MacTeX, and the Zulu JDKs live in `Brewfile.macos`, which `setup.sh` only installs on macOS. On Linux, `setup.sh` installs the Linux equivalents via `apt` instead: zathura (PDF viewer), a JDK, `texlive`, Roboto, and Nerd Font `.ttf` files pulled straight from the [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases). Source Code Pro / Source Sans 3 aren't in Ubuntu's repos under any stable name, so they're skipped on Linux — install manually if you want them (e.g. via `fc-list` + a manual download from Adobe's GitHub releases).
- **Docker** runs as a native daemon via `apt`/Docker Engine on Linux, instead of through colima's Linux VM on macOS.
- **Terminal app**: gnome-terminal, not iTerm2 — there's no `transparent`/`opaque` alias or password-manager trigger equivalent, so `iterm-alpha` and those aliases are defined only on macOS (guarded in `zshrc`).
- **Clipboard**: `mdf`'s copy-to-clipboard and `mdview`'s "open in default app" both branch on `$OSTYPE` — `xclip`/`xdg-open` on Linux, `pbcopy`/`open` on macOS.

## Keeping configs in sync

After changing any config file, commit and push from `~/myconfig`:

```bash
cd ~/myconfig
git add .
git commit -m "your message"
git push
```

On another machine, pull updates:

```bash
cd ~/myconfig
git pull --recurse-submodules
```

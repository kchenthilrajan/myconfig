# myconfig

Personal dotfiles for Neovim, tmux, Zsh (Oh My Zsh + Powerlevel10k), and macOS tooling.

## Contents

| Path | Description |
|------|-------------|
| `nvim/` | Neovim config (lazy.nvim) |
| `tmux/tmux.conf` | tmux config |
| `zsh/zshrc` | Zsh config with Oh My Zsh |
| `zsh/p10k.zsh` | Powerlevel10k prompt config |
| `zsh/omz-custom/` | Oh My Zsh custom plugins/themes |
| `Brewfile` | All Homebrew formulas, casks, and Nerd Fonts |

## New Machine Setup

### 1. Clone

```bash
git clone --recurse-submodules git@github-personal:kchenthilrajan/myconfig.git ~/myconfig
```

> `--recurse-submodules` pulls Powerlevel10k automatically.

### 2. Install Homebrew (if not present)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Install all tools and fonts

```bash
brew bundle install --file=~/myconfig/Brewfile
```

This installs Neovim, tmux, fzf, bat, eza, fd, glow, Nerd Fonts (Hack, JetBrains Mono, MesloLG), iTerm2, and everything else in the Brewfile.

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

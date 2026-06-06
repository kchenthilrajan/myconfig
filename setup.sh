#!/usr/bin/env bash
set -e

REPO="https://github.com/kchenthilrajan/myconfig.git"
DOTFILES="$HOME/myconfig"

echo "==> Setting up new Mac from $REPO"

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Clone repo
if [[ ! -d "$DOTFILES" ]]; then
  echo "==> Cloning myconfig"
  git clone "$REPO" "$DOTFILES"
else
  echo "==> myconfig already exists, pulling latest"
  git -C "$DOTFILES" pull
fi

# 3. Homebrew packages
echo "==> Installing Brew packages"
brew bundle install --file="$DOTFILES/Brewfile"

# 4. Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing Oh My Zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 5. Symlinks
echo "==> Creating symlinks"
symlink() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "  backing up $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

symlink "$DOTFILES/nvim"           "$HOME/.config/nvim"
symlink "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
symlink "$DOTFILES/zsh/zshrc"      "$HOME/.zshrc"
symlink "$DOTFILES/zsh/p10k.zsh"   "$HOME/.p10k.zsh"
symlink "$DOTFILES/zsh/omz-custom" "$HOME/.oh-my-zsh/custom"
symlink "$DOTFILES/w3m/keymap"     "$HOME/.w3m/keymap"

# 6. tmux plugin manager
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "==> Installing tpm (tmux plugin manager)"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 7. fzf shell integration
echo "==> Setting up fzf shell integration"
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true

# 8. Claude Code
if ! command -v claude &>/dev/null; then
  echo "==> Installing Claude Code"
  npm install -g @anthropic-ai/claude-code
fi

echo ""
echo "Done! Next steps:"
echo "  1. source ~/.zshrc"
echo "  2. Open tmux and press prefix + I to install tmux plugins"
echo "  3. Open nvim — Lazy will auto-install plugins on first launch"
echo "  4. Set iTerm2 profile and import settings manually"
echo "  5. Run 'claude' and log in to authenticate Claude Code"

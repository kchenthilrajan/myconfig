#!/usr/bin/env bash
set -e

REPO="https://github.com/kchenthilrajan/myconfig.git"
DOTFILES="$HOME/myconfig"
OS="$(uname -s)"

echo "==> Setting up new machine ($OS) from $REPO"

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew"
  if [[ "$OS" == "Linux" ]]; then
    sudo apt-get update
    sudo apt-get install -y build-essential procps curl file git
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ "$OS" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# 2. Clone repo
if [[ ! -d "$DOTFILES" ]]; then
  echo "==> Cloning myconfig"
  git clone "$REPO" "$DOTFILES"
else
  echo "==> myconfig already exists, pulling latest"
  git -C "$DOTFILES" pull
fi
git -C "$DOTFILES" submodule update --init --recursive

# 3. Homebrew packages
echo "==> Installing Brew packages"
brew bundle install --file="$DOTFILES/Brewfile"
if [[ "$OS" == "Darwin" ]]; then
  echo "==> Installing macOS-only Brew packages"
  brew bundle install --file="$DOTFILES/Brewfile.macos"
fi

# 3a. Linux-native packages Homebrew casks can't provide on Linux
if [[ "$OS" == "Linux" ]]; then
  echo "==> Installing Linux-native packages (zsh, zathura, JDK, LaTeX, fonts)"
  sudo apt-get install -y \
    zsh \
    zathura zathura-pdf-poppler \
    openjdk-21-jdk \
    texlive texlive-latex-extra \
    fonts-roboto

  # Docker Engine — a native daemon on Linux, unlike macOS where colima
  # provides it via a Linux VM (see Brewfile.macos). Installed via Docker's
  # official apt repo rather than the get.docker.com convenience script,
  # which misdetects Linux Mint as Debian and configures the wrong repo
  # (trixie instead of Mint's underlying Ubuntu noble base) — using
  # UBUNTU_CODENAME directly from /etc/os-release sidesteps that.
  if ! command -v docker &>/dev/null; then
    echo "==> Installing Docker Engine"
    . /etc/os-release
    CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $CODENAME stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    echo "    (log out/in for docker group membership to take effect)"
  fi

  # Nerd Fonts — the patched glyph builds aren't in apt, so grab them directly
  echo "==> Installing Nerd Fonts (JetBrainsMono, Hack, Meslo)"
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  for font in JetBrainsMono Hack Meslo; do
    if ! fc-list | grep -qi "$font Nerd Font"; then
      curl -fsSLo /tmp/"$font".zip \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip"
      unzip -oq /tmp/"$font".zip -d "$FONT_DIR" '*.ttf'
      rm /tmp/"$font".zip
    fi
  done
  fc-cache -f "$FONT_DIR"
fi

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
echo "  1. Set zsh as your default shell: chsh -s \$(which zsh)"
echo "  2. source ~/.zshrc"
echo "  3. Open tmux and press prefix + I to install tmux plugins"
echo "  4. Open nvim — Lazy will auto-install plugins on first launch"
if [[ "$OS" == "Linux" ]]; then
  echo "  5. Log out and back in for Docker group membership to take effect"
fi
echo "  6. Run 'claude' and log in to authenticate Claude Code"

#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/01_detect.sh"

echo "==> Installing Neovim and configuring plugins (lazy.nvim)"

case "$PKG_MGR" in
  apt)
    sudo apt-get update
    sudo apt-get install -y neovim curl git ripgrep fd-find
    command -v fd >/dev/null 2>&1 || sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd || true
    ;;
  dnf)
    sudo dnf install -y neovim curl git ripgrep fd-find
    ;;
  pacman)
    sudo pacman -Sy --noconfirm neovim curl git ripgrep fd
    ;;
  zypper)
    sudo zypper --non-interactive install -y neovim curl git ripgrep fd
    ;;
  brew)
    brew install neovim curl git ripgrep fd
    ;;
esac

NVIM_DIR="$HOME/.config/nvim"
if [ -d "$NVIM_DIR" ]; then
  mv "$NVIM_DIR" "$NVIM_DIR.bak.$(date +%s)" || true
fi
mkdir -p "$NVIM_DIR"/lua/plugins

# Deploy config
cp "$(dirname "$DIR")/dotfiles/nvim/init.lua" "$NVIM_DIR/"
cp -r "$(dirname "$DIR")/dotfiles/nvim/lua" "$NVIM_DIR/"

echo "-> Bootstrapping plugins (headless)"
nvim --headless '+Lazy! sync' '+qall' || true

echo "✅ Neovim setup complete."

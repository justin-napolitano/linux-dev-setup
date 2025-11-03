#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/01_detect.sh"

echo "==> Installing zsh, oh-my-zsh, p10k, and plugins"

case "$PKG_MGR" in
  apt)
    sudo apt-get update
    sudo apt-get install -y zsh git curl wget fzf
    ;;
  dnf)
    sudo dnf install -y zsh git curl wget fzf
    ;;
  pacman)
    sudo pacman -Sy --noconfirm zsh git curl wget fzf
    ;;
  zypper)
    sudo zypper refresh
    sudo zypper --non-interactive install -y zsh git curl wget fzf
    ;;
  brew)
    brew install zsh git curl wget fzf
    ;;
esac

# oh-my-zsh (non-interactive)
export RUNZSH=no
export CHSH=no
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "-> Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "-> oh-my-zsh already present"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# p10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Plugins
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ -d "$ZSH_CUSTOM/plugins/zsh-completions" ] || git clone --depth=1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
[ -d "$ZSH_CUSTOM/plugins/history-substring-search" ] || git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/history-substring-search"

# Write .zshrc if missing; otherwise ensure critical bits exist
ZSHRC="$HOME/.zshrc"
if [ ! -f "$ZSHRC" ]; then
  cp "$(dirname "$DIR")/dotfiles/.zshrc" "$ZSHRC"
else
  # Ensure theme & plugins are set
  sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC" || true
  if ! grep -q '^plugins=.*git' "$ZSHRC"; then
    sed -i.bak '/^plugins=/d' "$ZSHRC" || true
    echo 'plugins=(git z fzf asdf colored-man-pages docker kubectl zsh-autosuggestions zsh-syntax-highlighting zsh-completions history-substring-search)' >> "$ZSHRC"
  fi
  # Source p10k if present
  if ! grep -q 'p10k.zsh' "$ZSHRC"; then
    echo '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' >> "$ZSHRC"
  fi
fi

# p10k profile: pick ASCII if NO_ICONS is set
if [ -n "${NO_ICONS:-}" ]; then
  cp "$(dirname "$DIR")/dotfiles/.p10k_ascii.zsh" "$HOME/.p10k.zsh"
else
  cp "$(dirname "$DIR")/dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
fi

# Default shell to zsh (may require relogin)
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  if chsh -s "$(command -v zsh)" "$USER"; then
    echo "-> Default shell set to zsh"
  else
    echo "-> Could not change default shell automatically; run: chsh -s $(command -v zsh) $USER" >&2
  fi
fi

echo "✅ zsh/oh-my-zsh/p10k setup complete."

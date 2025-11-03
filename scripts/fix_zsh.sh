#!/usr/bin/env bash
set -euo pipefail

echo "==> Fixing zsh / oh-my-zsh / p10k setup"

ZSHRC="$HOME/.zshrc"
BACKUP_SUFFIX=".$(date +%s).bak"

# Ensure zsh installed
if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh not installed. Please run: make install-shell"
  exit 1
fi

# Ensure OMZ
export RUNZSH=no CHSH=no
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Ensure plugins/themes
[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ -d "$ZSH_CUSTOM/plugins/zsh-completions" ] || git clone --depth=1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
[ -d "$ZSH_CUSTOM/plugins/history-substring-search" ] || git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/history-substring-search"

# Rebuild .zshrc (preserving a backup)
if [ -f "$ZSHRC" ]; then
  cp "$ZSHRC" "$ZSHRC$BACKUP_SUFFIX"
fi
cat > "$ZSHRC" <<"EOF"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git z fzf asdf colored-man-pages docker kubectl zsh-autosuggestions zsh-syntax-highlighting zsh-completions history-substring-search)
source $ZSH/oh-my-zsh.sh

# History & quality-of-life
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS SHARE_HISTORY INC_APPEND_HISTORY
export EDITOR="nvim"

# direnv (if installed)
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# fzf key-bindings (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# asdf (if installed)
[ -f "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"

# p10k
[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh
EOF

# p10k profile (ASCII if NO_ICONS)
if [ -n "${NO_ICONS:-}" ]; then
  cp "$(dirname "$0")/../dotfiles/.p10k_ascii.zsh" "$HOME/.p10k.zsh"
else
  cp "$(dirname "$0")/../dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
fi

# default shell
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)" "$USER" || true
fi

echo "✅ zsh environment repaired. Previous .zshrc backed up as $ZSHRC$BACKUP_SUFFIX"

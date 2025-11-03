#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/01_detect.sh"

echo "==> Installing headless CLIs"

case "$PKG_MGR" in
  apt)
    sudo apt-get update
    sudo apt-get install -y \
      git curl wget unzip ca-certificates jq python3 python3-pip python3-venv \
      ripgrep fd-find fzf bat eza yq duf ncdu htop btop lnav rsync zip tar
    command -v fd >/dev/null 2>&1 || sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd || true
    ;;
  dnf)
    sudo dnf install -y git curl wget unzip ca-certificates jq python3-pip \
      ripgrep fd-find fzf bat eza yq duf ncdu htop btop lnav rsync zip tar
    ;;
  pacman)
    sudo pacman -Sy --noconfirm \
      git curl wget unzip ca-certificates jq python ripgrep fd fzf bat eza yq duf ncdu htop btop lnav rsync zip tar
    ;;
  zypper)
    sudo zypper --non-interactive install -y \
      git curl wget unzip ca-certificates jq python3 python3-pip \
      ripgrep fd fzf bat eza yq duf ncdu htop btop lnav rsync zip tar
    ;;
  brew)
    brew install git curl wget unzip jq python ripgrep fd fzf bat eza yq duf ncdu htop btop lnav rsync zip gnu-tar
    ;;
esac

# pipx for isolated CLI installs
python3 -m pip install --user --upgrade pip pipx
python3 -m pipx ensurepath || true

# direnv + gh
case "$PKG_MGR" in
  apt)
    sudo apt-get install -y direnv
    ;;
  *)
    if ! command -v direnv >/dev/null 2>&1; then
      curl -fsSL https://direnv.net/install.sh | bash
      sudo mv direnv /usr/local/bin/direnv || true
    fi
    ;;
esac

if ! command -v gh >/dev/null 2>&1; then
  case "$PKG_MGR" in
    apt) type -p curl >/dev/null || sudo apt-get install -y curl
         curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
         sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
         echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
         sudo apt-get update && sudo apt-get install -y gh ;;
    dnf) sudo dnf install -y gh ;;
    pacman) sudo pacman -Sy --noconfirm github-cli ;;
    zypper) sudo zypper --non-interactive install -y gh ;;
    brew) brew install gh ;;
  esac
fi

# Hook direnv into zsh if present
if command -v zsh >/dev/null 2>&1; then
  if ! grep -q 'direnv hook zsh' "$HOME/.zshrc" 2>/dev/null; then
    echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
  fi
fi

echo "✅ Headless tools installed."

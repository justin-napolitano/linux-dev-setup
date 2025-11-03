#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/01_detect.sh"

echo "==> Installing container tools"

case "$PKG_MGR" in
  apt)
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose-plugin
    sudo systemctl enable --now docker || true
    ;;
  dnf)
    sudo dnf install -y moby-engine moby-compose
    sudo systemctl enable --now docker || true
    ;;
  pacman)
    sudo pacman -Sy --noconfirm docker docker-compose
    sudo systemctl enable --now docker || true
    ;;
  zypper)
    sudo zypper --non-interactive install -y docker docker-compose
    sudo systemctl enable --now docker || true
    ;;
  brew)
    echo "-> On Homebrew Linux, install Docker Desktop or moby via your distro."
    ;;
esac

sudo usermod -aG docker "$USER" || true

# Optional: rootless mode (export ROOTLESS_DOCKER=1)
if [ "${ROOTLESS_DOCKER:-0}" = "1" ]; then
  echo "-> Enabling rootless Docker"
  export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
  sudo -u "$USER" dockerd-rootless-setuptool.sh install || true
  echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.zshrc"
  echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> "$HOME/.zshrc"
fi

echo "✅ Containers setup complete."

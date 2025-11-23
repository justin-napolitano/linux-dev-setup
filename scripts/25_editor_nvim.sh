#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/01_detect.sh"

echo "==> Installing Neovim and configuring plugins (lazy.nvim)"

# ---------- helpers ----------
ver_ge () {  # ver_ge <have> <need>  -> 0 if have >= need
  [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

have_modern_nvim () {
  if ! command -v nvim >/dev/null 2>&1; then return 1; fi
  local ver
  ver="$(nvim --version | head -n1 | sed -E 's/.*v([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/')"
  ver_ge "$ver" "0.8.0"
}

install_via_ppa_if_apt () {
  if [ "$PKG_MGR" != "apt" ]; then return 0; fi
  sudo apt-get update
  sudo apt-get install -y curl git ripgrep fd-find software-properties-common
  command -v fd >/dev/null 2>&1 || sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd || true

  # Add/update the official Neovim PPA (stable)
  sudo add-apt-repository -y ppa:neovim-ppa/stable || true
  sudo apt-get update || true
  sudo apt-get install -y neovim || true
}

install_via_pkg () {
  case "$PKG_MGR" in
    dnf)    sudo dnf install -y neovim curl git ripgrep fd-find || true ;;
    pacman) sudo pacman -Sy --noconfirm neovim curl git ripgrep fd || true ;;
    zypper) sudo zypper --non-interactive install -y neovim curl git ripgrep fd || true ;;
    brew)   brew install neovim curl git ripgrep fd || true ;;
  esac
}

fetch() {  # fetch <url> <outfile>
  local url="$1" out="$2"
  if curl -fsI "$url" >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
    return 0
  fi
  return 1
}

install_appimage_fallback () {
  echo "-> Installing Neovim via AppImage fallback"
  local out="/tmp/nvim.appimage"
  local tried=0

  # Try common asset names (GitHub varies between these)
  for url in \
    "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage" \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.appimage"
  do
    if fetch "$url" "$out"; then
      tried=1; break
    fi
  done

  if [ "$tried" -ne 1 ]; then
    echo "-> AppImage not available; trying .deb package"
    # Debian/Ubuntu-only: install the prebuilt .deb
    local deb="/tmp/nvim-linux64.deb"
    if fetch "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.deb" "$deb"; then
      sudo apt-get install -y libfuse2 || true  # some systems need it
      sudo dpkg -i "$deb" || sudo apt -f install -y
      return 0
    fi

    echo "-> .deb not available; trying portable tarball"
    local tgz="/tmp/nvim-linux64.tar.gz"
    if fetch "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" "$tgz"; then
      sudo mkdir -p /usr/local/nvim
      sudo tar -C /usr/local/nvim -xzf "$tgz" --strip-components=1
      echo "/usr/local/nvim/bin" | sudo tee /etc/profile.d/nvim_path.sh >/dev/null
      sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
      return 0
    fi

    echo "!! Could not fetch Neovim from GitHub releases."
    return 1
  fi

  chmod +x "$out"
  sudo mv "$out" /usr/local/bin/nvim
}

# ---------- install flow ----------
if [ "$PKG_MGR" = "apt" ]; then
  install_via_ppa_if_apt
else
  install_via_pkg
fi

if ! have_modern_nvim; then
  echo "-> System package provides old Neovim; using GitHub release fallback"
  install_appimage_fallback
fi

echo "-> Using Neovim at: $(command -v nvim)"
nvim --version | head -n1

# ---------- deploy config ----------
REPO_ROOT="$(cd "$DIR/.." && pwd)"
NVIM_DIR="$HOME/.config/nvim"
if [ -d "$NVIM_DIR" ]; then
  mv "$NVIM_DIR" "$NVIM_DIR.bak.$(date +%s)" || true
fi
mkdir -p "$NVIM_DIR"/lua/plugins
cp "$REPO_ROOT/dotfiles/nvim/init.lua" "$NVIM_DIR/"
cp -r "$REPO_ROOT/dotfiles/nvim/lua" "$NVIM_DIR/"

# Only run Lazy sync on supported versions
if have_modern_nvim; then
  echo "-> Bootstrapping plugins (headless)"
  nvim --headless '+Lazy! sync' '+qall' || true
else
  echo "-> Skipping Lazy sync because Neovim < 0.8"
fi

echo "✅ Neovim setup complete."


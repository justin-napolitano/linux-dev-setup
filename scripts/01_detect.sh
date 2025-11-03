#!/usr/bin/env bash
set -euo pipefail

if command -v apt >/dev/null 2>&1; then
  PKG_MGR="apt";    SUDO_INSTALL="sudo apt-get install -y"
elif command -v dnf >/dev/null 2>&1; then
  PKG_MGR="dnf";    SUDO_INSTALL="sudo dnf install -y"
elif command -v pacman >/dev/null 2>&1; then
  PKG_MGR="pacman"; SUDO_INSTALL="sudo pacman -Sy --noconfirm"
elif command -v zypper >/dev/null 2>&1; then
  PKG_MGR="zypper"; SUDO_INSTALL="sudo zypper --non-interactive install -y"
elif command -v brew >/dev/null 2>&1; then
  PKG_MGR="brew";   SUDO_INSTALL="brew install"
else
  echo "Unsupported distro: no known package manager found." >&2; exit 1
fi

DISTRO="$(. /etc/os-release 2>/dev/null && echo "${ID:-unknown}")"
export PKG_MGR SUDO_INSTALL DISTRO

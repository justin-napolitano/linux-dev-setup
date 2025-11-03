#!/usr/bin/env bash
set -euo pipefail

echo "==> Fixing Neovim configuration"

if ! command -v nvim >/dev/null 2>&1; then
  echo "Neovim not installed. Run: make install-editor"
  exit 1
fi

NVIM_DIR="$HOME/.config/nvim"
BACKUP="$NVIM_DIR.bak.$(date +%s)"

if [ -d "$NVIM_DIR" ]; then
  mv "$NVIM_DIR" "$BACKUP"
  echo "-> Backed up existing nvim config to $BACKUP"
fi

mkdir -p "$NVIM_DIR"

# Reinstall config from this repo (assumes make is run from cloned repo)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cp "$REPO_ROOT/dotfiles/nvim/init.lua" "$NVIM_DIR/"
cp -r "$REPO_ROOT/dotfiles/nvim/lua" "$NVIM_DIR/"

echo "-> Bootstrapping plugins (headless)"
nvim --headless '+Lazy! sync' '+qall' || true

echo "✅ Neovim config repaired."

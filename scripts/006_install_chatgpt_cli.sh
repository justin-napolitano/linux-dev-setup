#!/usr/bin/env bash
# install_chatgpt_cli.sh — install chatgpt CLI via npm
set -euo pipefail

log(){ echo "[chatgpt-cli] $*" >&2; }

if command -v apt >/dev/null 2>&1; then
  sudo apt update -y
  sudo apt install -y nodejs npm
elif command -v brew >/dev/null 2>&1; then
  brew update
  brew install node || true
else
  log "No apt or brew found. Ensure Node.js/npm are installed."
fi

if ! command -v npm >/dev/null 2>&1; then
  log "npm not found in PATH."
  exit 1
fi

sudo npm install -g chatgpt-cli
# Emit the CLI name to stdout for chaining
echo "chatgpt"


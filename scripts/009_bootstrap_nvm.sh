#!/usr/bin/env bash
set -euo pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ ! -d "$NVM_DIR" ]]; then
  echo "[nvm] installing..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Load nvm for this session
# shellcheck disable=SC1090
. "$NVM_DIR/nvm.sh"

# Install & set Node 22 as default
nvm install 22
nvm alias default 22
nvm use default

echo "[nvm] using $(node -v)"


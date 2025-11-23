#!/usr/bin/env bash
# =====================================================
# ChatGPT + Codex CLI Setup Script
# Author: cobra
# Purpose: Installs and configures ChatGPT CLI and Codex
# Compatible: Ubuntu / Debian / macOS
# =====================================================

set -e

API_KEY_FILE="$HOME/.openai_api_key"
BASHRC_FILE="$HOME/.bashrc"
ZSHRC_FILE="$HOME/.zshrc"

# --- FUNCTIONS ---
log() { echo -e "\033[1;32m[INFO]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

# --- SYSTEM CHECK ---
log "Updating system and installing prerequisites..."
if command -v apt >/dev/null 2>&1; then
  sudo apt update -y
  sudo apt install -y nodejs npm python3-pip
elif command -v brew >/dev/null 2>&1; then
  brew update
  brew install node python
else
  error "No supported package manager found (apt or brew)."
fi

# --- INSTALL CHATGPT CLI ---
log "Installing ChatGPT CLI..."
sudo npm install -g chatgpt-cli || error "Failed to install chatgpt-cli"

# --- INSTALL OPENAI CLI (Codex/General API) ---
log "Installing OpenAI Python client..."
pip install --upgrade openai || error "Failed to install OpenAI Python client"

# --- API KEY SETUP ---
if [[ -f "$API_KEY_FILE" ]]; then
  log "✅ Found existing API key file at $API_KEY_FILE"
else
  echo
  echo "------------------------------------------------------"
  echo "🔑 No existing OpenAI API key file found."
  read -rp "Enter your OpenAI API key: " OPENAI_API_KEY
  echo "------------------------------------------------------"
  if [[ -z "$OPENAI_API_KEY" ]]; then
    error "API key cannot be empty. Exiting."
  fi

  echo "export OPENAI_API_KEY=\"$OPENAI_API_KEY\"" > "$API_KEY_FILE"
  chmod 600 "$API_KEY_FILE"
  log "Saved API key to $API_KEY_FILE"
fi

# --- SHELL CONFIG ---
if [[ -n "$ZSH_VERSION" ]]; then
  SHELL_RC="$ZSHRC_FILE"
else
  SHELL_RC="$BASHRC_FILE"
fi

if ! grep -q "source $API_KEY_FILE" "$SHELL_RC"; then
  echo "source $API_KEY_FILE" >> "$SHELL_RC"
  log "Linked API key file in $SHELL_RC"
else
  log "API key file already sourced in $SHELL_RC"
fi

# --- VALIDATION ---
log "Validating installation..."

node -v || warn "Node.js missing"
npm -v || warn "npm missing"
python3 --version || warn "Python3 missing"

log "Testing OpenAI setup..."
if python3 - <<'EOF'
import openai, os
key = os.getenv("OPENAI_API_KEY")
if not key:
    raise SystemExit("❌ No API key found in environment.")
print("✅ API key loaded successfully.")
EOF
then
  log "✅ OpenAI environment validated."
else
  error "Failed to validate OpenAI setup."
fi

log "✨ All done!"
echo
echo "👉 Run 'chatgpt' to start ChatGPT CLI"
echo "👉 Run 'openai api completions.create -m gpt-4o-mini -p \"Hello\"' to test Codex/CLI"


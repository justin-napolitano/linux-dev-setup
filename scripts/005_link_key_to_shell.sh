#!/usr/bin/env bash
# link_key_to_shell.sh — source key file from zsh configs
set -euo pipefail

KEY_FILE="${1:-${OPENAI_KEY_FILE:-$HOME/.openai_api_key}}"
ZSHRC="$HOME/.zshrc"
ZPROFILE="$HOME/.zprofile"

[[ -f "$KEY_FILE" ]] || { echo "Key file not found: $KEY_FILE" >&2; exit 1; }

link_once() {
  local rc="$1"
  [[ -f "$rc" ]] || touch "$rc"
  if ! grep -Fq "source $KEY_FILE" "$rc"; then
    cp "$rc" "$rc.bak.$(date +%Y%m%d%H%M%S)"
    echo "source $KEY_FILE" >> "$rc"
    echo "$rc"
  fi
}

# Print any files we modified (to stdout)
link_once "$ZSHRC" || true
link_once "$ZPROFILE" || true


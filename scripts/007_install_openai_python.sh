#!/usr/bin/env bash
# install_openai_python.sh — install OpenAI Python client
set -euo pipefail

log(){ echo "[openai-py] $*" >&2; }

if command -v apt >/dev/null 2>&1; then
  sudo apt update -y
  sudo apt install -y python3 python3-pip
elif command -v brew >/dev/null 2>&1; then
  brew update
  brew install python || true
fi

PY=python3
command -v "$PY" >/dev/null 2>&1 || { log "python3 not found"; exit 1; }

"$PY" -m pip install --upgrade pip >/dev/null 2>&1 || true
"$PY" -m pip install --upgrade openai

echo "$PY"


#!/usr/bin/env bash
# ensure_openai_key.sh — create/manage ~/.openai_api_key safely
set -euo pipefail

KEY_FILE="${OPENAI_KEY_FILE:-$HOME/.openai_api_key}"
MODE="auto"   # auto | prompt | noninteractive
PRINT_KEY="no"

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--file PATH] [--prompt | --noninteractive] [--key KEY] [--print-key] [--quiet]
  --file PATH          Path to key file (default: $KEY_FILE)
  --prompt             Force prompt even if not a TTY (reads from /dev/tty)
  --noninteractive     Fail if key missing unless provided via --key or OPENAI_API_KEY
  --key KEY            Provide the key via argument (use with --noninteractive)
  --print-key          Print the key to stdout (DANGEROUS; use only in trusted pipelines)
  --quiet              Only print the key file path (or key if --print-key)
Exit codes:
  0 = success; 1 = generic failure; 2 = missing key in noninteractive mode
USAGE
}

QUIET="no"
ARG_KEY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) KEY_FILE="$2"; shift 2;;
    --prompt) MODE="prompt"; shift;;
    --noninteractive) MODE="noninteractive"; shift;;
    --key) ARG_KEY="$2"; shift 2;;
    --print-key) PRINT_KEY="yes"; shift;;
    --quiet) QUIET="yes"; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

log(){ [[ "$QUIET" == "yes" ]] || echo "[ensure] $*" >&2; }

mkdir -p "$(dirname "$KEY_FILE")"

# If exists, done
if [[ -f "$KEY_FILE" ]]; then
  # Fall through to output section
  :
else
  # Need a key
  KEY_SRC="${ARG_KEY:-${OPENAI_API_KEY:-}}"
  if [[ -z "$KEY_SRC" ]]; then
    if [[ "$MODE" == "noninteractive" ]]; then
      log "No key provided and noninteractive mode set."
      exit 2
    fi
    # Prompt (auto if TTY, or forced with --prompt)
    if [[ -t 0 || "$MODE" == "prompt" ]]; then
      # read from /dev/tty to stay interactive even in pipelines
      read -rs -p "Enter your OpenAI API key: " KEY_SRC < /dev/tty || true
      echo >&2
      if [[ -z "${KEY_SRC:-}" ]]; then
        log "Empty key. Aborting."
        exit 1
      fi
    else
      log "No TTY available to prompt. Use --noninteractive with --key or OPENAI_API_KEY."
      exit 2
    fi
  fi

  printf 'export OPENAI_API_KEY="%s"\n' "$KEY_SRC" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  log "Wrote key to $KEY_FILE"
fi

# Output
if [[ "$PRINT_KEY" == "yes" ]]; then
  # print the key (explicitly requested)
  # shellcheck disable=SC1090
  . "$KEY_FILE"
  printf '%s\n' "$OPENAI_API_KEY"
else
  printf '%s\n' "$KEY_FILE"
fi


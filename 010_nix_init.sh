#!/usr/bin/env bash
# scripts/010_nix_init.sh — Nix quick init for portable dev shells
set -euo pipefail

# ---------------- Options ----------------
INSTALL_DIRENV=1         # --no-direnv to skip
WRITE_FLAKE=1            # --no-flake to skip writing flake.nix if missing
RUN_SETUP=0              # --run-setup to run: nix develop -c make chatgpt-all
WITH_NVM=0               # --with-nvm to install nvm and Node 22 for non-Nix shells
FALLBACK_NODE_MAJOR=22   # nvm node version to set if --with-nvm

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--no-direnv] [--no-flake] [--run-setup] [--with-nvm]
  --no-direnv   Skip installing direnv + nix-direnv and writing .envrc
  --no-flake    Do not create flake.nix if missing
  --run-setup   After bootstrapping, run: nix develop -c make chatgpt-all
  --with-nvm    Install nvm and set Node ${FALLBACK_NODE_MAJOR} for non-Nix shells
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-direnv) INSTALL_DIRENV=0; shift;;
    --no-flake)  WRITE_FLAKE=0;   shift;;
    --run-setup) RUN_SETUP=1;     shift;;
    --with-nvm)  WITH_NVM=1;      shift;;
    -h|--help)   usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

log()  { echo -e "\033[1;32m[nix-init]\033[0m $*"; }
warn() { echo -e "\033[1;33m[nix-init]\033[0m $*" >&2; }
err()  { echo -e "\033[1;31m[nix-init]\033[0m $*" >&2; exit 1; }

# ---------------- 1) Install Nix (single-user) ----------------
if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix (single-user)..."
  if command -v curl >/dev/null 2>&1; then
    sh <(curl -fsSL https://nixos.org/nix/install) --no-daemon
  else
    err "curl not found; please install curl first."
  fi
else
  log "Nix already installed."
fi

# Ensure nix in this shell (macOS/Linux)
if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
  # shellcheck disable=SC1090
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# ---------------- 2) Enable flakes ----------------
mkdir -p "$HOME/.config/nix"
NIX_CONF="$HOME/.config/nix/nix.conf"
if [[ ! -f "$NIX_CONF" ]] || ! grep -q "experimental-features" "$NIX_CONF"; then
  log "Enabling nix-command flakes in $NIX_CONF"
  {
    echo "experimental-features = nix-command flakes"
  } >> "$NIX_CONF"
else
  log "Flakes already enabled in $NIX_CONF"
fi

# Reload profile if needed
if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
  # shellcheck disable=SC1090
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# ---------------- 3) direnv + nix-direnv ----------------
if (( INSTALL_DIRENV )); then
  if ! command -v direnv >/dev/null 2>&1; then
    log "Installing direnv + nix-direnv via nix profile..."
    nix profile install nixpkgs#direnv nixpkgs#nix-direnv
  else
    log "direnv already installed."
  fi

  if [[ ! -f ".envrc" ]]; then
    log "Writing .envrc (use flake) and allowing direnv"
    echo "use flake" > .envrc
  elif ! grep -q "use flake" .envrc; then
    log "Appending 'use flake' to existing .envrc"
    echo "use flake" >> .envrc
  else
    log ".envrc already configured for flakes."
  fi

  if command -v direnv >/dev/null 2>&1; then
    direnv allow || true
  fi
else
  log "Skipping direnv setup (--no-direnv)."
fi

# ---------------- 4) Write flake.nix if missing ----------------
if (( WRITE_FLAKE )) && [[ ! -f "flake.nix" ]]; then
  log "Creating minimal flake.nix (Node 22, Python 3.12, etc.)"
  cat > flake.nix <<'FLAKE'
{
  description = "Portable dev shell for scripts repo";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
  let
    forAll = f: {
      x86_64-linux = f "x86_64-linux";
      aarch64-linux = f "aarch64-linux";
      x86_64-darwin = f "x86_64-darwin";
      aarch64-darwin = f "aarch64-darwin";
    };
  in {
    devShells = forAll (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            bashInteractive gnumake coreutils gnused gawk findutils
            git curl wget jq unzip
            zsh
            python312 python312Packages.pip
            nodejs_22
            openssh
          ];
          shellHook = ''
            export NPM_CONFIG_PREFIX="$PWD/.npm-global"
            export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

            export PIPX_HOME="$PWD/.pipx"
            export PIPX_BIN_DIR="$PWD/.pipx/bin"
            export PATH="$PIPX_BIN_DIR:$PATH"

            if [ -f "$HOME/.openai_api_key" ]; then
              . "$HOME/.openai_api_key"
            elif [ -f ".secrets/openai_api_key" ]; then
              export OPENAI_API_KEY="$(cat .secrets/openai_api_key)"
            fi

            echo "Dev shell ready:"
            echo "  node: $(node -v) | npm: $(npm -v) | python: $(python3 --version | awk '{print $2}')"
            echo "Use: nix develop -c make chatgpt-all"
          '';
        };
      });
  };
}
FLAKE
else
  log "flake.nix present (skipping write)."
fi

# ---------------- 5) Optional: install nvm for non-Nix shells ----------------
if (( WITH_NVM )); then
  if [[ -x "scripts/009_bootstrap_nvm.sh" ]]; then
    log "Installing nvm + Node ${FALLBACK_NODE_MAJOR} via scripts/009_bootstrap_nvm.sh"
    bash scripts/009_bootstrap_nvm.sh
  else
    log "Installing nvm inline (scripts/009_bootstrap_nvm.sh not found)"
    NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [[ ! -d "$NVM_DIR" ]]; then
      curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
    # shellcheck disable=SC1090
    . "$NVM_DIR/nvm.sh"
    nvm install "${FALLBACK_NODE_MAJOR}"
    nvm alias default "${FALLBACK_NODE_MAJOR}"
    nvm use default
    log "nvm ready (node $(node -v))"
  fi
fi

# ---------------- 6) Optional: run your setup inside the dev shell ----------------
if (( RUN_SETUP )); then
  log "Running: nix develop -c make chatgpt-all"
  nix develop -c bash -lc "make chatgpt-all"
fi

log "Done. Tip: run 'nix develop' then 'make chatgpt-all'"


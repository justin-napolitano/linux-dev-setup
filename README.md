# Linux Dev Setup (Headless-friendly)

A streamlined repository to bootstrap a Linux development environment optimized for headless servers. It automates the installation and configuration of essential tools, shells, editors, containers, and optional security hardening.

## Features

- Automatic Linux distribution detection supporting apt, dnf, pacman, zypper, and brew.
- Shell setup with oh-my-zsh and Powerlevel10k prompt, including ASCII fallback for terminals without Nerd Font support.
- Neovim configured with lazy.nvim and popular plugins such as Treesitter, LSP, and Telescope.
- Container tools including Docker with optional rootless mode.
- Utilities like direnv, fzf, ripgrep, fd, bat, eza, jq, and yq.
- Optional security hardening with ufw, fail2ban, and sshd configurations.
- Repair targets for zsh and neovim configurations.

## Tech Stack

- Shell scripting for automation.
- Makefile orchestration for modular installation steps.
- Nix flake support (flake.nix present) for reproducible environments.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/justin-napolitano/linux-dev-setup.git
cd linux-dev-setup
```

Run the full installation:

```bash
make install
```

Alternatively, run specific installation components:

```bash
make install-shell       # Setup shell environment
make install-editor      # Setup Neovim editor
make install-headless    # Install headless tools
make install-containers  # Setup container tools (Docker etc.)
make install-security    # Optional security hardening
make fix-zsh             # Repair zsh, oh-my-zsh, Powerlevel10k & plugins
make fix-vim             # Repair Neovim config & plugins
```

### Environment Flags

- `ROOTLESS_DOCKER=1` enables rootless Docker during container installation.
- `NO_ICONS=1` forces ASCII Powerlevel10k prompt without Nerd Font glyphs.

## Project Structure

```
010_nix_init.sh        # Nix initialization script
flake.nix              # Nix flake configuration
Makefile               # Orchestrates installation and fixes
Makefile.bak           # Backup of Makefile
README.md              # Project documentation
scripts/               # Installation and fix scripts
  ├─ 004_ensure_openai_key.sh  # ChatGPT/OpenAI key management
  ├─ 005_link_key_to_shell.sh  # Link OpenAI key to shell environment
  ├─ 006_install_chatgpt_cli.sh # Install ChatGPT CLI
  ├─ 007_install_openai_python.sh # Install OpenAI Python client
  ├─ 008_verify_openai_env.sh  # Verify OpenAI environment variables
  ├─ 009_bootstrap_nvm.sh      # Node Version Manager bootstrap
  ├─ 12_shell.sh               # Shell environment setup
  ├─ 25_editor_nvim.sh         # Neovim setup
  ├─ 35_headless_tools.sh      # Headless tool installation
  ├─ 36_containers.sh          # Container tools setup
  ├─ 50_security.sh            # Security hardening setup
  ├─ fix_zsh.sh                # Fix zsh environment
  └─ fix_vim.sh                # Fix Neovim environment

dotfiles/               # User dotfiles (assumed)

```

## Future Work / Roadmap

- Expand support for additional Linux distributions and package managers.
- Enhance Nix flake integration for fully reproducible environments.
- Add more granular configuration options for installed tools.
- Integrate automated testing for installation scripts.
- Extend security hardening with audit and compliance checks.

---

This setup aims to simplify and standardize Linux development environment provisioning, especially for headless or remote servers.
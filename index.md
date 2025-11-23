---
slug: "github-linux-dev-setup"
title: "linux-dev-setup"
repo: "justin-napolitano/linux-dev-setup"
githubUrl: "https://github.com/justin-napolitano/linux-dev-setup"
generatedAt: "2025-11-23T09:14:04.109039Z"
source: "github-auto"
---


# Linux Dev Setup: Technical Overview and Implementation Notes

## Motivation and Problem Statement

Setting up a consistent Linux development environment across diverse distributions and headless servers is a recurring challenge. Manual installations are error-prone and time-consuming, especially when dealing with multiple components like shells, editors, containers, and security configurations. This repository addresses the problem by providing automated, modular scripts to bootstrap a full-featured development environment with minimal manual intervention.

## Design and Architecture

The project is structured around a Makefile that orchestrates various shell scripts, each responsible for a distinct portion of the setup:

- Shell environment (`install-shell`)
- Editor setup (`install-editor`)
- Headless tools (`install-headless`)
- Container tools (`install-containers`)
- Security hardening (`install-security`)

The Makefile targets allow both full and partial installs, enabling flexibility and incremental setup.

### Distribution Detection

The scripts auto-detect the Linux distribution and select the appropriate package manager among apt, dnf, pacman, zypper, and brew. This abstraction allows the same scripts to run on a wide range of distributions without modification.

### Shell Environment

The shell setup installs and configures `oh-my-zsh` with the Powerlevel10k theme. It includes a fallback to ASCII prompts for terminals without Nerd Font support, controlled by the `NO_ICONS` environment variable.

### Editor Setup

Neovim is installed and configured with `lazy.nvim` as the plugin manager. Popular plugins such as Treesitter for syntax parsing, LSP for language server support, and Telescope for fuzzy finding are included. This ensures a modern, extensible editor environment.

### Containers

Docker is installed with an option to enable rootless mode via the `ROOTLESS_DOCKER` flag. This enhances security and usability on systems where root privileges are restricted.

### Security

Security hardening is implemented as an opt-in feature, configuring firewall rules with `ufw`, intrusion prevention with `fail2ban`, and securing SSH daemon settings. This modular approach allows users to enable security features as needed.

### Repair Targets

Additional Makefile targets `fix-zsh` and `fix-vim` are provided to repair or refresh existing configurations, facilitating maintenance and updates.

## Implementation Details

- **Makefile**: Uses Bash as the shell and defines `.PHONY` targets for idempotent operations. It also includes a set of scripts related to OpenAI/ChatGPT CLI setup, indicating auxiliary tooling support.

- **Scripts**: Located in the `scripts/` directory, these are named with numeric prefixes to indicate order or grouping. Each script focuses on a specific task, e.g., `12_shell.sh` for shell setup, `25_editor_nvim.sh` for editor setup.

- **Nix Integration**: The presence of `flake.nix` and `010_nix_init.sh` suggests experimental or partial support for Nix-based reproducible environments, though details are sparse.

- **Environment Variables**: The Makefile and scripts respect environment variables for customization, such as `ROOTLESS_DOCKER` and `NO_ICONS`. This design allows flexible behavior without modifying scripts.

## Practical Considerations

- The modular design supports partial installs, which is useful for iterative setup or troubleshooting.

- The scripts assume a Bash environment and executable permissions on scripts, enforced by the `check-chatgpt-scripts` target.

- Security hardening is opt-in, recognizing that not all users require or want these changes.

- The approach balances automation with transparency, encouraging users to review scripts before execution.

## Summary

This repository provides a pragmatic, modular approach to Linux development environment setup, emphasizing compatibility across distributions and headless operation. It leverages shell scripting and Makefile orchestration to automate installation and configuration of shells, editors, containers, and security features. The design choices reflect practical trade-offs between automation, flexibility, and user control.

The setup is suitable for developers and engineers seeking a repeatable, maintainable Linux dev environment provisioning process without reliance on heavyweight configuration management tools.
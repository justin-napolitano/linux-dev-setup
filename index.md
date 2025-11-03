+++
title =  "Headless Linux Dev Setup"
description = "Automating complete development environment setup for Linux servers with zsh, Neovim, and modern CLI tooling."
tags = ["linux", "devops", "dotfiles", "automation", "neovim", "zsh"]
images = ["images/linux-dev-setup-feature.png"]
date = "2025-11-02T14:25:13-05:00"
categories = ["projects"]
series = ["automation", "dev-environment"]
[extra]
lang = "en"
toc = true
comment = false
copy = true
outdate_alert = true
outdate_alert_days = 180
math = false
mermaid = false
featured = true
reaction = true
+++

# 🐧 Headless Linux Dev Setup

After building several developer workstations and CI servers by hand, I finally decided to automate it all.  
This project provides a **single-command bootstrap** for setting up a full developer environment on Linux — tailored for **headless systems** and **terminal-first workflows**.

👉 **Repo:** [https://github.com/justin-napolitano/linux-dev-setup.git](https://github.com/justin-napolitano/linux-dev-setup.git)

---

## ⚡ Overview

This setup automatically detects your distro (`apt`, `dnf`, `pacman`, `zypper`, or `brew`) and installs everything needed for a modern developer shell and editor environment.

It’s especially tuned for **servers**, **VMs**, and **remote instances** where you live inside SSH and want a frictionless setup.

**Includes:**
- `zsh` + `oh-my-zsh` + `Powerlevel10k` (auto-detects Nerd Fonts, ASCII fallback)
- `Neovim` + `lazy.nvim` + Treesitter, LSP, Telescope, Git integration
- CLI favorites: `ripgrep`, `fd`, `fzf`, `bat`, `eza`, `jq`, `yq`, `direnv`, `gh`
- Optional Docker (rootless mode supported)
- Optional SSH hardening, `ufw`, and `fail2ban`

---

## 🧠 Philosophy

> “Headless doesn’t have to mean basic.”

The goal is a **zero-click**, **idempotent** setup:
- Rerunnable safely — existing configs are backed up before updates.
- No GUI dependencies.
- Focused on real-world DevOps and analytics workflows.
- All scripts are plain bash and versionable alongside dotfiles.

---

## 🚀 Quick Start

```bash
git clone https://github.com/justin-napolitano/linux-dev-setup.git
cd linux-dev-setup
make install
```

Or, if you’re just fixing an existing machine:
```bash
make fix-zsh
make fix-vim
```

**Optional Flags:**
```bash
NO_ICONS=1 ROOTLESS_DOCKER=1 make install
```

- `NO_ICONS=1` → ASCII prompt (for terminals without Nerd Fonts)
- `ROOTLESS_DOCKER=1` → install Docker rootless mode
- `SKIP_SECURITY=1` → skip optional security tweaks

---

## 🧩 Stack Highlights

### 🌀 Zsh Shell
- **oh-my-zsh** framework  
- **Powerlevel10k** theme (auto ASCII fallback)
- Plugins:
  `git`, `z`, `fzf`, `asdf`, `colored-man-pages`, `docker`, `kubectl`,  
  plus `zsh-autosuggestions`, `zsh-syntax-highlighting`, and more.

### 📝 Neovim
- Plugin manager: **lazy.nvim**
- Plugins: Treesitter, Telescope, Gitsigns, LSP, Autopairs, Comment, Which-Key
- Theme: **Catppuccin** (with Gruvbox available)
- Optimized for SSH — minimal redraw, no GUI dependencies.

### ⚙️ Headless Tools
`ripgrep`, `fd`, `fzf`, `bat`, `eza`, `jq`, `yq`, `duf`, `ncdu`, `btop`, `lnav`, `rsync`,  
`direnv`, `gh`, and more.

### 🐳 Containers
- Docker + Compose plugin
- Optional rootless Docker (`ROOTLESS_DOCKER=1`)

### 🔒 Optional Security
- SSH hardening (no root login or password auth)
- `ufw` firewall
- `fail2ban`

---

## 🧰 Repair Scripts

If your existing environment is half-configured or broken:

```bash
make fix-zsh   # Rebuilds zsh, oh-my-zsh, p10k, and plugin setup
make fix-vim   # Restores Neovim config and plugin set
```

Each creates a timestamped backup of your old configs.

---

## 🧩 Extensible Design

The repo is modular — each layer (shell, editor, headless tools, containers, security) is isolated in its own script under `scripts/`.

This makes it easy to:
- Add new CLI tools
- Swap out editors
- Customize dotfiles
- Re-run setup safely across multiple servers

---

## 🧑‍💻 Why Build This?

For analysts, engineers, and DevOps folks who frequently spin up new servers, WSL environments, or remote dev containers — this project gives you a consistent, tuned baseline that *feels like home* the moment you SSH in.

---

## 🔗 Project Link

👉 [https://github.com/justin-napolitano/linux-dev-setup.git](https://github.com/justin-napolitano/linux-dev-setup.git)

---

## 📄 License

MIT — free to use, modify, and share.

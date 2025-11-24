---
slug: github-linux-dev-setup-note-technical-overview
id: github-linux-dev-setup-note-technical-overview
title: Linux Dev Setup Overview
repo: justin-napolitano/linux-dev-setup
githubUrl: https://github.com/justin-napolitano/linux-dev-setup
generatedAt: '2025-11-24T18:40:36.151Z'
source: github-auto
summary: >-
  This repo helps you bootstrap a Linux development environment, especially for
  headless servers. It automates the installation of essential tools, shells,
  editors, and more.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: note
entryLayout: note
showInProjects: false
showInNotes: true
showInWriting: false
showInLogs: false
---

This repo helps you bootstrap a Linux development environment, especially for headless servers. It automates the installation of essential tools, shells, editors, and more.

## Key Features:
- Auto-detects Linux distributions using `apt`, `dnf`, `pacman`, `zypper`, and `brew`.
- Sets up `oh-my-zsh` with Powerlevel10k, plus a fallback for ASCII terminals.
- Configures Neovim with popular plugins via `lazy.nvim`.
- Installs container tools like Docker, with optional rootless mode.
- Provides utilities like `fzf`, `bat`, `jq`, and more.
- Offers optional security hardening using `ufw` and `fail2ban`.

## Quick Start:
Clone the repo and install:

```bash
git clone https://github.com/justin-napolitano/linux-dev-setup.git
cd linux-dev-setup
make install
```

### Environment Flags:
- Set `ROOTLESS_DOCKER=1` for rootless Docker.
- Use `NO_ICONS=1` for ASCII Powerlevel10k.

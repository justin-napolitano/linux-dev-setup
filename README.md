# Linux Dev Setup (Headless-friendly)

This repo bootstraps a Linux development environment focused on headless servers.

## Quick start
```bash
# review the scripts if you like, then:
make install
# or run specific parts:
make install-shell
make install-editor
make install-headless
make install-containers
make install-security   # optional, disabled by default
make fix-zsh            # repairs existing zsh/oh-my-zsh/p10k & plugins
make fix-vim            # repairs existing neovim config & plugins
```
### Notes
- Distro auto-detected; supports apt/dnf/pacman/zypper/brew.
- Neovim + lazy.nvim + popular plugins (Treesitter, LSP, Telescope, etc.).
- oh-my-zsh + Powerlevel10k with ASCII fallback for non-nerd-font terminals.
- Docker (rootless toggle), direnv, fzf, ripgrep, fd, bat, eza, jq, yq, etc.
- Security hardening (ufw, fail2ban, sshd) is available, opt-in.

## Flags / Environment
- `ROOTLESS_DOCKER=1` to enable rootless docker in `make install-containers`.
- `NO_ICONS=1` to force ASCII Powerlevel10k prompt (no Nerd Font glyphs).

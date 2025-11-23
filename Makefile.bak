SHELL := /bin/bash

.PHONY: install install-shell install-editor install-headless install-containers install-security fix-zsh fix-vim

install: install-shell install-headless install-editor install-containers
	@echo "✅ Full install complete."

install-shell:
	bash scripts/12_shell.sh

install-editor:
	bash scripts/25_editor_nvim.sh

install-headless:
	bash scripts/35_headless_tools.sh

install-containers:
	bash scripts/36_containers.sh

install-security:
	bash scripts/50_security.sh

fix-zsh:
	bash scripts/fix_zsh.sh

fix-vim:
	bash scripts/fix_vim.sh

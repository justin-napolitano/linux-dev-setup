SHELL := /bin/bash

# ---------------- Existing targets ----------------
.PHONY: install install-shell install-editor install-headless install-containers install-security fix-zsh fix-vim

install: install-shell install-headless install-editor install-containers
	@echo "✅ Full install complete."

# Add to your existing Makefile:

.PHONY: install-nvm
install-nvm:
	bash scripts/009_bootstrap_nvm.sh

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

# ---------------- ChatGPT/OpenAI setup ----------------
# Helper scripts expected in ./scripts:
#   004_ensure_openai_key.sh
#   005_link_key_to_shell.sh
#   006_install_chatgpt_cli.sh
#   007_install_openai_python.sh
#   008_verify_openai_env.sh

# Configurable vars (override at call time as needed)
OPENAI_KEY_FILE ?= $(HOME)/.openai_api_key
# For non-interactive runs, pass: OPENAI_API_KEY=sk-XXX make ensure-key link

CHATGPT_SCRIPTS := \
	scripts/004_ensure_openai_key.sh \
	scripts/005_link_key_to_shell.sh \
	scripts/006_install_chatgpt_cli.sh \
	scripts/007_install_openai_python.sh \
	scripts/008_verify_openai_env.sh

.PHONY: chatgpt-all ensure-key link install-cli install-py verify reload-env check-chatgpt-scripts

check-chatgpt-scripts:
	@for s in $(CHATGPT_SCRIPTS); do \
		if [[ ! -x "$$s" ]]; then \
			echo "Missing or not executable: $$s" >&2; exit 1; \
		fi; \
	done

# 1) Ensure key exists (prompts if TTY)
ensure-key: check-chatgpt-scripts
	@echo "[make] ensure-key -> $(OPENAI_KEY_FILE)" >&2
	@OPENAI_KEY_FILE="$(OPENAI_KEY_FILE)" \
	  $(if $(OPENAI_API_KEY),OPENAI_API_KEY="$(OPENAI_API_KEY)",) \
	  scripts/004_ensure_openai_key.sh --quiet > /tmp/openai_keyfile_path.$$$$ && \
	echo "[make] key file: $$(cat /tmp/openai_keyfile_path.$$$$)" >&2

# 2) Link key into zsh startup (~/.zshrc and ~/.zprofile; creates .bak)
link: check-chatgpt-scripts ensure-key
	@KEY_FILE="$$(cat /tmp/openai_keyfile_path.$$$$ 2>/dev/null || echo "$(OPENAI_KEY_FILE)")" ; \
	echo "[make] link -> $$KEY_FILE" >&2 ; \
	scripts/005_link_key_to_shell.sh "$$KEY_FILE" | sed 's/^/[linked] /' || true

# 3) Install ChatGPT CLI (npm)
install-cli: check-chatgpt-scripts
	@scripts/006_install_chatgpt_cli.sh >/dev/null && echo "chatgpt installed"

# 4) Install OpenAI Python client
install-py: check-chatgpt-scripts
	@scripts/007_install_openai_python.sh >/dev/null && echo "openai python ready"

# 5) Verify OPENAI_API_KEY is visible to current shell
verify: check-chatgpt-scripts
	@/bin/bash -lc 'source $$HOME/.zshrc >/dev/null 2>&1 || true; scripts/008_verify_openai_env.sh'

# Full ChatGPT/OpenAI setup pipeline
chatgpt-all: ensure-key link install-cli install-py verify
	@echo "[make] Completed ChatGPT/OpenAI setup."

# Handy: reload env in a subshell and verify (useful right after link)
reload-env: check-chatgpt-scripts
	@/bin/bash -lc 'source $$HOME/.zshrc >/dev/null 2>&1 || true; scripts/008_verify_openai_env.sh'


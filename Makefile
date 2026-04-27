UNAME := $(shell uname)
NVIM_CONFIG_DIR := $(HOME)/.config/nvim
REPO_DIR := $(shell pwd)

# ─── Default ──────────────────────────────────────────────────────────────────
.DEFAULT_GOAL := help

.PHONY: help install backup link deps go-tools python-tools node-tools uninstall

help:
	@echo ""
	@echo "  NeoVim Config — Installer"
	@echo ""
	@echo "  Usage: make <target>"
	@echo ""
	@echo "  Targets:"
	@echo "    install        Full install: backup + deps + tools + link config"
	@echo "    deps           Install system dependencies (ripgrep, fd, make, node)"
	@echo "    go-tools       Install Go language tools (gopls, gofumpt, etc.)"
	@echo "    python-tools   Install Python tools (pyright, black, isort, flake8)"
	@echo "    node-tools     Install Node.js tools (prettier)"
	@echo "    link           Symlink this repo to ~/.config/nvim"
	@echo "    backup         Backup existing ~/.config/nvim"
	@echo "    uninstall      Remove the symlink at ~/.config/nvim"
	@echo ""

# ─── Full install ─────────────────────────────────────────────────────────────
install: backup deps go-tools python-tools node-tools link
	@echo ""
	@echo "  Done! Open nvim — lazy.nvim will install all plugins on first launch."
	@echo ""

# ─── Backup existing config ───────────────────────────────────────────────────
backup:
	@if [ -e "$(NVIM_CONFIG_DIR)" ] && [ ! -L "$(NVIM_CONFIG_DIR)" ]; then \
		echo "  Backing up existing config to $(NVIM_CONFIG_DIR).bak ..."; \
		mv "$(NVIM_CONFIG_DIR)" "$(NVIM_CONFIG_DIR).bak"; \
	elif [ -L "$(NVIM_CONFIG_DIR)" ]; then \
		echo "  Removing existing symlink at $(NVIM_CONFIG_DIR) ..."; \
		rm "$(NVIM_CONFIG_DIR)"; \
	fi

# ─── Symlink config ───────────────────────────────────────────────────────────
link:
	@echo "  Linking $(REPO_DIR) → $(NVIM_CONFIG_DIR) ..."
	@mkdir -p "$(HOME)/.config"
	@ln -sf "$(REPO_DIR)" "$(NVIM_CONFIG_DIR)"
	@echo "  Config linked."

# ─── System dependencies ──────────────────────────────────────────────────────
deps:
ifeq ($(UNAME), Darwin)
	@echo "  [macOS] Installing system dependencies via Homebrew ..."
	@command -v brew >/dev/null 2>&1 || { \
		echo "  Homebrew not found. Installing..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	}
	brew install neovim ripgrep fd node make
else
	@echo "  [Linux] Installing system dependencies via apt ..."
	sudo apt-get update -qq
	sudo apt-get install -y neovim ripgrep fd-find nodejs npm make build-essential
	@# On Ubuntu/Debian, fd is installed as fdfind — create a symlink if needed
	@if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then \
		mkdir -p "$(HOME)/.local/bin" && \
		ln -sf "$$(which fdfind)" "$(HOME)/.local/bin/fd" && \
		echo "  Symlinked fdfind → ~/.local/bin/fd (add ~/.local/bin to PATH if needed)"; \
	fi
endif

# ─── Go tools ─────────────────────────────────────────────────────────────────
go-tools:
	@command -v go >/dev/null 2>&1 || { \
		echo "  ERROR: Go is not installed. Install it from https://go.dev/dl/ and re-run."; \
		exit 1; \
	}
	@echo "  Installing Go tools ..."
	go install golang.org/x/tools/gopls@latest
	go install mvdan.cc/gofumpt@latest
	go install golang.org/x/tools/cmd/goimports@latest
ifeq ($(UNAME), Darwin)
	@echo "  Installing golangci-lint (macOS) ..."
	brew install golangci-lint
else
	@echo "  Installing golangci-lint (Linux) ..."
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
		| sh -s -- -b $$(go env GOPATH)/bin latest
endif
	@echo "  Go tools installed."

# ─── Python tools ─────────────────────────────────────────────────────────────
python-tools:
	@command -v pip3 >/dev/null 2>&1 || command -v pip >/dev/null 2>&1 || { \
		echo "  ERROR: pip not found. Install Python 3 and pip, then re-run."; \
		exit 1; \
	}
	@echo "  Installing Python tools ..."
	pip3 install --upgrade pyright black isort flake8
	@echo "  Python tools installed."

# ─── Node.js tools ────────────────────────────────────────────────────────────
node-tools:
	@command -v npm >/dev/null 2>&1 || { \
		echo "  ERROR: npm not found. Install Node.js and re-run."; \
		exit 1; \
	}
	@echo "  Installing Node.js tools ..."
	npm install -g prettier
	@echo "  Node.js tools installed."

# ─── Uninstall ────────────────────────────────────────────────────────────────
uninstall:
	@if [ -L "$(NVIM_CONFIG_DIR)" ]; then \
		rm "$(NVIM_CONFIG_DIR)"; \
		echo "  Symlink removed. Restore your backup with:"; \
		echo "    mv $(NVIM_CONFIG_DIR).bak $(NVIM_CONFIG_DIR)"; \
	else \
		echo "  No symlink found at $(NVIM_CONFIG_DIR). Nothing to do."; \
	fi

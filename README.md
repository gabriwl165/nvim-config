# Neovim Configuration — Go & Python

A modern Neovim setup for **Go** and **Python** development, with LSP, completion, formatting, linting, fuzzy finding, Treesitter highlighting, and Claude Code integration.

> Looking for architecture, plugin internals, or contributor docs? See [AGENTS.md](AGENTS.md).

---

## Features

- LSP-powered intellisense (gopls, pyright, lua_ls)
- Format-on-save (gofumpt + goimports for Go, isort + black for Python)
- Linting (golangci-lint, flake8)
- Fuzzy finder (Telescope + fzf-native)
- File explorer, statusline, buffer tabs, indent guides, git signs
- Dashboard + notifications (snacks.nvim)
- Claude Code CLI integration

---

## Prerequisites

| Requirement | Minimum | Notes |
|-------------|---------|-------|
| Neovim | **0.11+** | Required for `vim.lsp.config` API |
| Git | any | Used by lazy.nvim to clone plugins |
| A Nerd Font | any | For icons — e.g. [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) |
| `make` | any | For `telescope-fzf-native` build step |
| `ripgrep` (`rg`) | any | Required by Telescope live grep |
| Node.js | 18+ | For Mason-installed servers + prettier |
| Go toolchain | 1.21+ | Optional — for Go development |
| Python | 3.9+ | Optional — for Python development |
| Claude Code CLI | latest | Optional — run `claude login` once to authenticate |

---

## Installation

### Quick install

```bash
git clone https://github.com/YOUR_USER/nvim-config.git ~/nvim-config
cd ~/nvim-config
make install
```

`make install` backs up your existing config, installs system + language tools (Homebrew on macOS, apt on Debian/Ubuntu), and symlinks the repo to `~/.config/nvim`.

| Make target | What it does |
|-------------|-------------|
| `make install` | Full install: backup + deps + tools + symlink |
| `make deps` | System packages only |
| `make go-tools` | Go tools only |
| `make python-tools` | Python tools only |
| `make node-tools` | Node tools only (prettier) |
| `make link` | Symlink repo → `~/.config/nvim` |
| `make backup` | Backup existing config to `~/.config/nvim.bak` |
| `make uninstall` | Remove the symlink |

### Manual install

```bash
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://github.com/YOUR_USER/nvim-config.git ~/.config/nvim
nvim
```

On first launch, lazy.nvim bootstraps and installs every plugin. Mason auto-installs `gopls`, `pyright`, and `lua_ls` on first use.

---

## Key Bindings

> **Leader key = `<Space>`**

### Essentials

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<Esc>` | Clear search highlight |
| `<leader>e` | Toggle file explorer |
| `<leader>L` | Open Lazy plugin manager |

### Find (Telescope)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep across project |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>fs` | Grep word under cursor |
| `<leader>fh` | Help tags |
| `<leader>ft` | Find TODOs |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>la` | Code action |
| `<leader>lr` | Rename symbol |
| `<leader>lf` | Format file |
| `<leader>li` | LSP info |
| `<leader>lm` | Open Mason |

### Diagnostics

| Key | Action |
|-----|--------|
| `<leader>d` | Open diagnostic float |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>xx` | Toggle Trouble panel |

### Buffers & Windows

| Key | Action |
|-----|--------|
| `<S-l>` / `<S-h>` | Next / previous buffer |
| `<leader>bd` | Delete buffer |
| `<C-h/j/k/l>` | Move between windows |
| `<leader>sv` / `<leader>sh` | Vertical / horizontal split |
| `<leader>sx` | Close current split |

### Editing

| Key | Action |
|-----|--------|
| `gcc` / `gc` (visual) | Toggle line / selection comment (Neovim native) |
| `<A-j>` / `<A-k>` | Move line down / up |
| `s` / `S` | Flash jump / Flash treesitter jump |
| `ys{motion}{char}` | Add surround |
| `cs{old}{new}` | Change surround |
| `ds{char}` | Delete surround |

### Git (gitsigns)

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next / previous hunk |
| `<leader>ghs` / `<leader>ghr` | Stage / reset hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame line |

### Go

| Key | Action |
|-----|--------|
| `<leader>gor` | `go run %` |
| `<leader>got` | `go test ./...` |
| `<leader>gob` | `go build ./...` |
| `<leader>goi` | `go mod tidy` |

### Python

| Key | Action |
|-----|--------|
| `<leader>pyr` | `python3 %` |
| `<leader>pyt` | `python3 -m pytest` |
| `<leader>pyv` | `python3 -m venv .venv` |

### AI (Claude Code)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ac` | Normal | Toggle Claude Code terminal |
| `<leader>as` | Visual | Send selection to Claude |
| `<leader>aS` | Normal | Send buffer to Claude |

---

## Coming from VSCode?

Neovim is modal — most shortcuts apply only in **Normal mode** (press `Esc` to get there). Leader is `Space`.

| VSCode | Neovim |
|--------|--------|
| `Ctrl+P` | `<leader>ff` |
| `Ctrl+Shift+F` | `<leader>fg` |
| `Ctrl+S` | `<leader>w` |
| `Ctrl+/` | `gcc` (or `gc` in visual) |
| `Ctrl+B` | `<leader>e` |
| `Ctrl+Shift+P` | `:` (ex command) |
| `F12` | `gd` |
| `Shift+F12` | `gr` |
| `F2` | `<leader>lr` |
| `Ctrl+.` | `<leader>la` |
| `Shift+Alt+F` | `<leader>lf` |
| `Ctrl+Space` | `<C-Space>` (insert mode) |
| `Alt+Up` / `Alt+Down` | `<A-k>` / `<A-j>` |
| `Ctrl+Tab` | `<S-l>` |

---

## Project Setup Tips

**Go** — make sure your project has a `go.mod`:

```bash
go mod init github.com/you/yourproject
```

`gopls` requires a module root. Create a `.golangci.yml` to configure linters:

```yaml
linters:
  enable: [errcheck, gosimple, govet, ineffassign, staticcheck, unused]
```

**Python** — Pyright auto-detects `.venv`:

```bash
python3 -m venv .venv
source .venv/bin/activate
nvim .
```

For flake8 + Black compatibility, add a `.flake8`:

```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Plugins not installing | `:Lazy sync`, or remove `~/.local/share/nvim/lazy` and restart |
| LSP not starting | `:LspInfo`, then `:Mason` to verify install; check `$PATH` |
| Formatter not running | `:ConformInfo`, then check `:messages` after save |
| Icons missing or boxed | Install a [Nerd Font](https://www.nerdfonts.com/) and set it as your terminal font |
| Treesitter highlighting wrong | `:TSUpdate` |

For deeper details (architecture, plugin internals, adding new languages), see [AGENTS.md](AGENTS.md).

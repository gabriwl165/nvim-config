# Neovim Configuration — Go & Python

A modern Neovim setup for **Go** and **Python** development, with LSP, completion, formatting, linting, fuzzy finding, Treesitter highlighting, and Claude Code integration.

> Looking for architecture, plugin internals, or contributor docs? See [AGENTS.md](AGENTS.md).

---

## Features

- LSP-powered intellisense (gopls, pyright, lua_ls)
- Format-on-save (gofumpt + goimports for Go, isort + black for Python)
- Linting (golangci-lint, flake8)
- Debugging via DAP (delve for Go, debugpy for Python; reads `.vscode/launch.json`)
- Fuzzy finder (Telescope + fzf-native)
- File explorer, statusline, buffer tabs, indent guides, git signs
- Full Git workflow (fugitive: `:Git`, blame, diff split, browse)
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
| `<leader>xx` | Toggle Trouble (workspace diagnostics) |
| `<leader>xd` | Trouble — current buffer diagnostics only |
| `<leader>xs` | Trouble — document symbols |
| `<leader>xl` | Trouble — LSP references / definitions |
| `<leader>xq` / `<leader>xL` | Trouble — quickfix / location list |

### Buffers (open files) & Windows (splits)

> **Mental model:**
> - **Buffers** are open files (one per file). `<S-l>` and `<S-h>` cycle through them.
> - **Windows** are visible panes/splits. `<C-h/j/k/l>` moves between them.
> - **Tabs** are whole layouts of windows (rarely needed). See below.

| Key | Action |
|-----|--------|
| `<S-l>` / `<S-h>` | Next / previous **buffer** (open file) |
| `<leader>fb` | Pick buffer with Telescope |
| `<leader>bd` | Close current buffer |
| `:e path/to/file` | Open another file in a new buffer |
| `<C-h/j/k/l>` | Move between **windows** (splits) |
| `<leader>sv` / `<leader>sh` | Vertical / horizontal split |
| `<leader>sx` | Close current split |
| `<leader><Tab>n` | New tab |
| `<leader><Tab>l` / `<leader><Tab>h` | Next / previous tab |
| `<leader><Tab>x` | Close tab |

### Terminal

Powered by `Snacks.terminal` — terminals are **persistent and toggleable**. Hide one and reopen it with the same shell, scrollback, and running process.

| Key | Action |
|-----|--------|
| `<C-/>` | Toggle floating scratch terminal (works in normal AND terminal mode) |
| `<leader>tt` | Toggle bottom-docked terminal (35% screen height) |
| `<leader>tv` | Toggle right-docked terminal (45% width) |
| `<leader>tf` | Toggle floating terminal (same as `<C-/>`) |
| `<Esc><Esc>` | Leave terminal-insert mode (so you can scroll/copy) |
| `<C-h/j/k/l>` | Jump to another window from inside the terminal |
| `i` / `a` | Re-enter terminal-insert mode |
| `q` (in normal mode inside terminal) | Close the floating window (process keeps running, reopen with same key) |
| `:bd!` | Permanently kill the terminal buffer + its process |

The bottom, right, and float terminals are **independent and persist** — they're three different terminals you can have running side-by-side. `<leader>gor`, `<leader>pyt`, etc. open a transient floating terminal that auto-disposes when you close it.

**Typical workflow when running Go/Python:**

1. `<leader>gor` → floating window pops up running `go run %`.
2. When done, press `q` in normal mode (or `<Esc><Esc>` then `q`) to close.
3. Or press `<C-/>` to hide it and pull up your scratch shell instead.

**Multiple terminals simultaneously:**

```
<leader>tt   → bottom terminal: long-running server
<leader>tv   → right terminal: tail logs
<C-/>        → floating: ad-hoc commands
```

Each one toggles independently. Hide and reopen freely — the processes keep running.

### Editing

| Key | Action |
|-----|--------|
| `gcc` / `gc` (visual) | Toggle line / selection comment (Neovim native) |
| `<A-j>` / `<A-k>` | Move line down / up |
| `s` / `S` | Flash jump / Flash treesitter jump |
| `ys{motion}{char}` | Add surround |
| `cs{old}{new}` | Change surround |
| `ds{char}` | Delete surround |

### Git — Fugitive (`tpope/vim-fugitive`)

Full Git wrapper. `:Git` (or `:G`) runs any git command; useful subcommands have shortcuts below.

| Key | Action |
|-----|--------|
| `<leader>gs` | Git status (interactive summary, press `g?` for help) |
| `<leader>gc` | Git commit |
| `<leader>gp` | Git pull |
| `<leader>gP` | Git push |
| `<leader>gb` | Git blame (current buffer) |
| `<leader>gd` | Git diff (split against index) |
| `<leader>gl` | Git log --oneline |
| `<leader>gw` | Stage current file (`:Gwrite`) |
| `<leader>gr` | Discard buffer changes (`:Gread`) |
| `<leader>gO` | Open file (or visual selection) in GitHub web UI (`:GBrowse`) |

### Git — Hunks (`gitsigns.nvim`)

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / previous hunk (`gs.nav_hunk`) |
| `<leader>ghs` / `<leader>ghr` | Stage / reset hunk |
| `<leader>ghS` / `<leader>ghR` | Stage / reset entire buffer |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame line (full info) |
| `<leader>ghd` | Diff this file |

### Go

| Key | Action |
|-----|--------|
| `<leader>gor` | `go run %` |
| `<leader>got` | `go test ./...` |
| `<leader>gob` | `go build ./...` |
| `<leader>goi` | `go mod tidy` |
| `<leader>god` | Debug Go (delve) — pick a config from `.vscode/launch.json`, or `dap-go` falls back to current file / package |
| `<leader>goD` | Debug nearest Go test (`dap-go.debug_test`) |

### Python

| Key | Action |
|-----|--------|
| `<leader>pyr` | `python3 %` |
| `<leader>pyt` | `python3 -m pytest` |
| `<leader>pyv` | `python3 -m venv .venv` |
| `<leader>pyd` | Debug Python (debugpy) — current file or `.vscode/launch.json` config |
| `<leader>pyD` | Debug nearest pytest method (`dap-python.test_method`) |

### Debugging (DAP)

Powered by [`nvim-dap`](https://github.com/mfussenegger/nvim-dap) with `dap-ui`, virtual text, delve (Go), and debugpy (Python). Adapters are auto-installed on first use via `mason-nvim-dap`.

**Workflow:** drop a breakpoint with `<leader>Db` (or `<F9>`) → press `<leader>god` / `<leader>pyd` (or `<F5>`) to start. A picker shows the available configurations; the `dap-ui` panels (scopes, watches, breakpoints, stacks, repl, console) open automatically and close when the session ends.

**Configurations come from two sources, with no setup required:**

1. **Built-in defaults** from `nvim-dap-go` and `nvim-dap-python` — debug current file, debug package, debug nearest test, run pytest, etc. These work in any project, no `launch.json` needed.
2. **`.vscode/launch.json`** — auto-loaded on startup when present, so any per-project configuration (custom `buildFlags`, `env`, `args`, `cwd`...) is reused as-is.

To scaffold a starter `.vscode/launch.json` in the current project, run `:DapInit` (or `<leader>DI`). It writes a template with sensible Go + Python configs and refuses to overwrite an existing file (use `:DapInit!` to force). After editing, reload with `<leader>DL`.

#### Session controls

| Key | Action |
|-----|--------|
| `<F5>` / `<leader>Dc` | Start / continue |
| `<F10>` / `<leader>Dn` | Step over (next) |
| `<F11>` / `<leader>Di` | Step into |
| `<F12>` / `<leader>Do` | Step out |
| `<F9>` / `<leader>Db` | Toggle breakpoint |
| `<leader>DB` | Conditional breakpoint (prompts for expression) |
| `<leader>Dl` | Run last configuration |
| `<leader>Dr` | Toggle DAP REPL |
| `<leader>Dq` | Terminate session |
| `<leader>Dh` | Hover variable under cursor |
| `<leader>De` | Evaluate expression (visual selection or word under cursor) |
| `<leader>Du` | Toggle the `dap-ui` panels |
| `<leader>DL` | Reload `.vscode/launch.json` |
| `<leader>DI` | Bootstrap `.vscode/launch.json` template (`:DapInit`) |

#### Per-project configuration

Most projects don't need anything — the built-in defaults handle "debug current file / package / test" out of the box. Add a `.vscode/launch.json` only when you need:

- **Custom build flags** (e.g. `"buildFlags": "-tags integration"`).
- **Environment variables** (e.g. CGO paths, API keys) that aren't already exported in your shell.
- **Program arguments** or a non-default `cwd`.
- **Multiple named entry points** (e.g. server vs. CLI vs. worker).

Run `:DapInit` to drop a starter file; edit it to taste, then `<leader>DL` to reload. If your debug session depends on env vars set by a Makefile, either launch Neovim from a shell where they're exported, or move them under each config's `env` key.

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

# NeoVim Configuration — Go & Python

A modern NeoVim setup built with **lazy.nvim**, targeting Go and Python development.
Includes LSP, auto-completion, formatting, linting, fuzzy finding, and a polished UI.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Installation](#2-installation)
3. [Directory Structure](#3-directory-structure)
4. [Core Configuration](#4-core-configuration)
   - [options.lua](#optionslua)
   - [keymaps.lua](#keymapslua)
   - [autocmds.lua](#autocmdslua)
5. [Plugin System](#5-plugin-system)
6. [Plugins Explained](#6-plugins-explained)
   - [UI](#ui-pluginsuilua)
   - [Editor](#editor-pluginseditorlua)
   - [LSP](#lsp-pluginslsplua)
   - [Completion](#completion-pluginscompletionlua)
   - [Treesitter](#treesitter-pluginstreesitterlua)
   - [Telescope](#telescope-pluginsTelescopelua)
7. [Go Development](#7-go-development)
8. [Python Development](#8-python-development)
9. [Key Bindings Reference](#9-key-bindings-reference)
10. [External Tools Required](#10-external-tools-required)
11. [Adding a New Language](#11-adding-a-new-language)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Prerequisites

| Requirement | Minimum version | Notes |
|-------------|----------------|-------|
| NeoVim | **0.10+** | Required for modern LSP APIs |
| Git | any | Used by lazy.nvim to clone plugins |
| A Nerd Font | any | Required by icons (e.g. [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)) |
| `make` | any | Required by `telescope-fzf-native` build step |
| Node.js | 18+ | Required by several Mason-installed LSP servers |
| Go toolchain | 1.21+ | Required for Go development |
| Python | 3.9+ | Required for Python development |
| `ripgrep` (`rg`) | any | Required by Telescope live grep |
| `fd` | any | Optional — faster file finder for Telescope |

---

## 2. Installation

### 2.1 Quick install (recommended)

Clone the repo anywhere and run `make install`. It will back up your existing config, install all system dependencies and language tools, and symlink the repo to `~/.config/nvim`.

```bash
git clone https://github.com/YOUR_USER/nvim-config.git ~/nvim-config
cd ~/nvim-config
make install
```

**Available Makefile targets:**

| Target | Description |
|--------|-------------|
| `make install` | Full install: backup + deps + all tools + symlink |
| `make deps` | System packages only (neovim, ripgrep, fd, node) |
| `make go-tools` | Go tools only (gopls, gofumpt, goimports, golangci-lint) |
| `make python-tools` | Python tools only (pyright, black, isort, flake8) |
| `make node-tools` | Node.js tools only (prettier) |
| `make link` | Symlink repo → `~/.config/nvim` (no tool installs) |
| `make backup` | Backup existing config to `~/.config/nvim.bak` |
| `make uninstall` | Remove the symlink |

The Makefile detects the OS automatically and uses **Homebrew** on macOS or **apt** on Debian/Ubuntu.

---

### 2.2 Manual install

#### Back up your existing config (if any)

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
```

#### Clone this repository

```bash
git clone https://github.com/YOUR_USER/nvim-config.git ~/.config/nvim
```

### 2.3 Install external tools

#### Go tools

```bash
# gopls — Go language server
go install golang.org/x/tools/gopls@latest

# gofumpt — stricter gofmt
go install mvdan.cc/gofumpt@latest

# goimports — auto-manage import blocks
go install golang.org/x/tools/cmd/goimports@latest

# golangci-lint — meta-linter
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
    | sh -s -- -b $(go env GOPATH)/bin latest
```

#### Python tools

```bash
pip install pyright black isort flake8
# or, inside a virtual environment:
pip install pyright black isort flake8
```

#### Other (formatting / Telescope)

```bash
# stylua — Lua formatter (for editing this config)
cargo install stylua
# OR via npm:
npm install -g @johnnymorganz/stylua-bin

# prettier — JSON / YAML / Markdown formatter
npm install -g prettier

# ripgrep — required by Telescope live_grep
# Ubuntu/Debian:
sudo apt install ripgrep
# macOS:
brew install ripgrep
```

### 2.4 First launch

Open NeoVim. **lazy.nvim** will automatically bootstrap itself and install all plugins:

```bash
nvim
```

After installation completes:
- Run `:MasonUpdate` to refresh Mason's registry.
- Mason will auto-install `gopls`, `pyright`, and `lua_ls` on first use.
- Run `:TSUpdate` if any Treesitter parsers fail to install.

---

## 3. Directory Structure

```
~/.config/nvim/
├── init.lua                  ← Entry point: loads core + plugins
└── lua/
    ├── core/
    │   ├── options.lua       ← Vim options (tabs, numbers, clipboard…)
    │   ├── keymaps.lua       ← All key mappings
    │   └── autocmds.lua      ← Auto-commands (format-on-save, filetype tweaks…)
    └── plugins/
        ├── init.lua          ← lazy.nvim bootstrap + plugin spec import
        ├── ui.lua            ← Colorscheme, statusline, file explorer, git signs…
        ├── editor.lua        ← Autopairs, comments, formatting, linting…
        ├── lsp.lua           ← Mason, nvim-lspconfig, gopls, pyright…
        ├── completion.lua    ← nvim-cmp + LuaSnip
        ├── treesitter.lua    ← Syntax highlighting + text objects
        └── telescope.lua     ← Fuzzy finder
```

---

## 4. Core Configuration

### `options.lua`

Sets fundamental Vim/NeoVim options. Key choices:

| Option | Value | Reason |
|--------|-------|--------|
| `number` + `relativenumber` | true | Absolute current line + relative for motions |
| `tabstop` / `shiftwidth` | 4 | Go and Python both use 4-wide indentation |
| `expandtab` | true (global) | Spaces by default; overridden to false for Go in `autocmds.lua` |
| `clipboard` | `unnamedplus` | Syncs the system clipboard with the `"` register |
| `undofile` | true | Persistent undo across sessions |
| `scrolloff` | 8 | Always keeps 8 lines visible above/below the cursor |
| `foldmethod` | `expr` (treesitter) | Code folding driven by the syntax tree |
| `colorcolumn` | 100 | Visual ruler; overridden to 120 for Go and 88 for Python |

### `keymaps.lua`

Sets `<Space>` as the **leader key**. All keymaps use `noremap = true, silent = true`.

See the full [Key Bindings Reference](#9-key-bindings-reference) section below.

### `autocmds.lua`

| Auto-command | Trigger | Effect |
|-------------|---------|--------|
| `YankHighlight` | `TextYankPost` | Briefly highlights yanked text |
| `TrimWhitespace` | `BufWritePre *` | Removes trailing spaces on every save |
| `ResizeSplits` | `VimResized` | Re-equalises split sizes when terminal is resized |
| `GoSettings` | `FileType go` | Switches to real tabs (`expandtab=false`), 120-char ruler |
| `PythonSettings` | `FileType python` | Ensures 4-space indent, 88-char ruler (Black default) |
| `RestoreCursor` | `BufReadPost` | Jumps to the last known cursor position when reopening a file |
| `CloseWithQ` | `FileType help,qf,…` | Lets you close auxiliary windows with just `q` |
| `AutoFormat` | `BufWritePre *.go,*.py` | Runs `conform.nvim` on Go and Python files on every save |

---

## 5. Plugin System

Plugins are managed by **[lazy.nvim](https://github.com/folke/lazy.nvim)**, a modern plugin manager with:

- Lazy-loading (plugins load only when needed)
- Automatic bootstrapping on first launch
- A built-in UI (`<leader>L` or `:Lazy`)
- Lockfile (`lazy-lock.json`) for reproducible installs

Plugin specs are split into focused files under `lua/plugins/` and imported via the `spec` table in `lua/plugins/init.lua`.

---

## 6. Plugins Explained

### UI (`plugins/ui.lua`)

#### `folke/tokyonight.nvim`

A dark colorscheme with good contrast and Treesitter-aware highlights.
Style is set to `"night"`. Change the `style` option to `"storm"`, `"moon"`, or `"day"` if you prefer.

#### `nvim-lualine/lualine.nvim`

Status line at the bottom of the screen. Sections (left → right):

```
[mode] [branch|diff|diagnostics]  [filename]        [encoding|format|filetype] [progress] [line:col]
```

#### `akinsho/bufferline.nvim`

Renders open buffers as tabs at the top of the screen. Includes LSP diagnostic badges.
Navigate buffers with `Shift+h` (prev) and `Shift+l` (next).

#### `nvim-tree/nvim-tree.lua`

File explorer on the left side (30 columns wide). Toggle with `<leader>e`.
Shows git status icons next to each file.

#### `lukas-reineke/indent-blankline.nvim`

Draws vertical indent guide lines using `│` characters.
Scope highlighting (powered by Treesitter) marks the current block.

#### `lewis6991/gitsigns.nvim`

Shows git diff signs in the sign column (`+`, `~`, `_`).
Provides hunk-level staging, resetting, previewing, and blame.

#### `rcarriga/nvim-notify`

Replaces the default `vim.notify()` with a floating notification window.

#### `folke/which-key.nvim`

Shows a popup with available keybindings when you pause after pressing the leader or any prefix key.

#### `goolord/alpha-nvim`

A startup dashboard shown when NeoVim is opened without a file argument.

---

### Editor (`plugins/editor.lua`)

#### `windwp/nvim-autopairs`

Automatically inserts the closing bracket/quote/brace when you type the opening one.
Integrated with Treesitter to avoid inserting pairs inside strings.

#### `numToStr/Comment.nvim`

- `gcc` — toggle line comment
- `gbc` — toggle block comment
- `gc` in Visual mode — toggle comment on selection

Uses `nvim-ts-context-commentstring` to pick the correct comment style per embedded language (e.g., HTML inside Python templates).

#### `kylechui/nvim-surround`

Allows adding, changing, and deleting surrounding characters (quotes, brackets, tags).

| Keymap | Effect |
|--------|--------|
| `ys{motion}{char}` | Add surrounding |
| `cs{old}{new}` | Change surrounding |
| `ds{char}` | Delete surrounding |

#### `folke/flash.nvim`

Enhanced jump motions. Replaces the `s`/`S` keys:

- `s` — jump to any character on screen by typing a search label
- `S` — jump using Treesitter-aware node selection

#### `folke/todo-comments.nvim`

Highlights `TODO`, `FIXME`, `HACK`, `NOTE`, `WARN` in comments.
Search all TODOs project-wide with `<leader>ft`.

#### `folke/trouble.nvim`

A pretty diagnostics list.

| Keymap | Effect |
|--------|--------|
| `<leader>xx` | Toggle Trouble panel |
| `<leader>xw` | Workspace diagnostics |
| `<leader>xd` | Document diagnostics |

#### `stevearc/conform.nvim`

Formatter orchestrator. Configured formatters:

| Language | Formatters (in order) |
|----------|-----------------------|
| Go | `gofumpt` → `goimports` |
| Python | `isort` → `black` |
| Lua | `stylua` |
| JSON / YAML / Markdown | `prettier` |

Format-on-save is handled by the `AutoFormat` auto-command in `autocmds.lua`.
Manual format: `<leader>lf`.

#### `mfussenegger/nvim-lint`

Runs linters asynchronously on `BufEnter`, `BufWritePost`, and `InsertLeave`.

| Language | Linter |
|----------|--------|
| Go | `golangci-lint` |
| Python | `flake8` |

---

### LSP (`plugins/lsp.lua`)

#### `williamboman/mason.nvim`

A package manager for LSP servers, formatters, and linters.
Open with `<leader>lm` or `:Mason`. Install packages interactively inside the UI.

#### `neovim/nvim-lspconfig` + `williamboman/mason-lspconfig.nvim`

`mason-lspconfig` bridges Mason and `lspconfig`: servers installed via Mason are automatically registered and started by `lspconfig`.

`ensure_installed` auto-installs the following on first launch:

| Server | Language |
|--------|----------|
| `gopls` | Go |
| `pyright` | Python |
| `lua_ls` | Lua (for editing this config) |

#### On-attach keymaps (active in every buffer with an LSP)

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>la` | Code action |
| `<leader>lr` | Rename symbol |
| `<leader>ls` | Document symbols |
| `<leader>lS` | Workspace symbols |
| `<leader>li` | LSP info |

#### `gopls` settings

| Setting | Value | Effect |
|---------|-------|--------|
| `gofumpt` | true | Uses `gofumpt` for formatting inside `gopls` |
| `staticcheck` | true | Enables extra staticcheck analyses |
| `semanticTokens` | true | Enables semantic token highlighting |
| `analyses.nilness` | true | Reports nil pointer dereferences |
| `analyses.unusedparams` | true | Reports unused function parameters |
| `usePlaceholders` | true | Inserts function argument placeholders in completions |
| `completeUnimported` | true | Completes symbols from unimported packages |
| Inlay hints | all enabled | Shows types, parameter names, constant values inline |

#### `pyright` settings

| Setting | Value | Effect |
|---------|-------|--------|
| `typeCheckingMode` | `basic` | Flags clear type errors without being too strict |
| `autoSearchPaths` | true | Searches `src/` and other common paths |
| `useLibraryCodeForTypes` | true | Infers types from installed library stubs |
| `autoImportCompletion` | true | Suggests imports from installed packages |

#### `folke/neodev.nvim`

Provides NeoVim API type definitions and completion for `lua_ls`, making it fully aware of `vim.*` APIs when editing Lua configs.

---

### Completion (`plugins/completion.lua`)

#### `hrsh7th/nvim-cmp`

The completion engine. Sources are prioritised as follows:

| Priority | Source | Description |
|----------|--------|-------------|
| 1000 | `nvim_lsp` | LSP completions |
| 750 | `luasnip` | Snippet expansions |
| 500 | `buffer` | Words in open buffers |
| 250 | `path` | File system paths |

Completion also works in the command line (`/`, `?`, `:`).

**Key mappings in insert mode:**

| Key | Action |
|-----|--------|
| `<Tab>` | Select next item / expand or jump snippet |
| `<S-Tab>` | Select previous item / jump back in snippet |
| `<CR>` | Confirm selection |
| `<C-Space>` | Force open completion menu |
| `<C-e>` | Abort completion |
| `<C-b>` / `<C-f>` | Scroll documentation |

#### `L3MON4D3/LuaSnip` + `rafamadriz/friendly-snippets`

Snippet engine with a large collection of pre-built VSCode-compatible snippets for Go, Python, and many other languages.

---

### Treesitter (`plugins/treesitter.lua`)

#### `nvim-treesitter/nvim-treesitter`

Provides accurate, incremental syntax highlighting and indentation using a real syntax tree.

Pre-installed grammars:

- **Go**: `go`, `gomod`, `gosum`, `gowork`
- **Python**: `python`
- **Config/misc**: `lua`, `bash`, `json`, `yaml`, `toml`, `markdown`, `dockerfile`, `gitignore`, `sql`

`auto_install = true` will silently install a grammar the first time you open a file of that type.

#### `nvim-treesitter/nvim-treesitter-textobjects`

Adds semantic text objects based on the syntax tree. Works in normal, visual, and operator-pending modes.

**Select text objects:**

| Keymap | Object |
|--------|--------|
| `af` / `if` | Outer / inner function |
| `ac` / `ic` | Outer / inner class |
| `aa` / `ia` | Outer / inner parameter |
| `ab` / `ib` | Outer / inner block |

**Move between nodes:**

| Keymap | Jump |
|--------|------|
| `]f` / `[f` | Next / prev function start |
| `]F` / `[F` | Next / prev function end |
| `]c` / `[c` | Next / prev class start |

---

### Telescope (`plugins/telescope.lua`)

#### `nvim-telescope/telescope.nvim`

Fuzzy finder over files, text, buffers, help tags, and more.

Uses `telescope-fzf-native` (compiled C extension) for high-performance sorting and `telescope-ui-select` to replace NeoVim's built-in selection UI (used by LSP code actions, etc.).

**Inside a Telescope window:**

| Key | Action |
|-----|--------|
| `<C-j>` / `<C-k>` | Move selection down / up |
| `<CR>` | Open selected item |
| `<C-q>` | Send all results to quickfix list |
| `<Esc>` | Close |

---

## 7. Go Development

### What's configured

| Feature | Tool |
|---------|------|
| Language server | `gopls` |
| Format on save | `gofumpt` + `goimports` |
| Linting | `golangci-lint` |
| Tab style | Real tabs (`\t`), width 4 |
| Column ruler | 120 chars |
| Inlay hints | Variable types, parameter names, constant values |

### Workflow

```
<leader>gor   Run the current file (go run %)
<leader>got   Run all tests (go test ./...)
<leader>gob   Build all packages (go build ./...)
<leader>goi   Tidy modules (go mod tidy)
<leader>lf    Format manually
<leader>la    Code actions (extract variable, fill struct, etc.)
K             Hover docs for symbol under cursor
gd            Jump to definition
gr            Show all references
```

### Go project setup

Make sure you initialise a module before opening Go files:

```bash
go mod init github.com/you/yourproject
```

`gopls` requires a module root to work correctly. When you open any `.go` file, the LSP starts automatically.

### golangci-lint configuration

Create a `.golangci.yml` at the root of your project to configure which linters run:

```yaml
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
```

---

## 8. Python Development

### What's configured

| Feature | Tool |
|---------|------|
| Language server | `pyright` |
| Format on save | `isort` (import sorting) → `black` |
| Linting | `flake8` |
| Indent | 4 spaces, `expandtab = true` |
| Column ruler | 88 chars (Black's default line length) |

### Workflow

```
<leader>pyr   Run the current file (python3 %)
<leader>pyt   Run pytest
<leader>pyv   Create a virtual environment (.venv)
<leader>lf    Format manually
<leader>la    Code actions
K             Hover documentation
gd            Jump to definition
gr            Show all references
```

### Virtual environments

Pyright automatically detects `.venv` in the project root. Always activate your venv before starting NeoVim, or create one first:

```bash
python3 -m venv .venv
source .venv/bin/activate
nvim .
```

Pyright will pick up the interpreter from the active venv.

### flake8 configuration

Create a `.flake8` file at the project root:

```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
```

The `max-line-length = 88` and `extend-ignore` settings make flake8 compatible with Black.

---

## 9. Key Bindings Reference

> **Leader key = `<Space>`**

### General

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>Q` | Force quit all |
| `<Esc>` | Clear search highlight |

### Window & Split Management

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move between windows |
| `<C-Arrow>` | Resize current window |
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<leader>sx` | Close current split |

### Buffers

| Key | Action |
|-----|--------|
| `<S-l>` | Next buffer |
| `<S-h>` | Previous buffer |
| `<leader>bd` | Delete buffer |

### Editing

| Key | Action |
|-----|--------|
| `<A-j>` / `<A-k>` | Move line / selection down / up |
| `<` / `>` (visual) | Dedent / indent (stays in visual mode) |
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle comment on selection |
| `s` | Flash jump |
| `S` | Flash treesitter jump |

### File Explorer

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle NvimTree |
| `<leader>o` | Focus NvimTree |

### Telescope (Find)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>fs` | Grep word under cursor |
| `<leader>fh` | Help tags |
| `<leader>ft` | Find TODOs |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>la` | Code action |
| `<leader>lr` | Rename symbol |
| `<leader>ls` | Document symbols |
| `<leader>lS` | Workspace symbols |
| `<leader>lf` | Format file |
| `<leader>lm` | Open Mason |
| `<leader>li` | LSP info |

### Diagnostics & Trouble

| Key | Action |
|-----|--------|
| `<leader>d` | Open diagnostic float |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>xx` | Toggle Trouble panel |
| `<leader>xw` | Workspace diagnostics |
| `<leader>xd` | Document diagnostics |

### Git (gitsigns)

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next / prev hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage buffer |
| `<leader>ghR` | Reset buffer |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame line |
| `<leader>ghd` | Diff this |

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

---

## 10. External Tools Required

Install all tools so Mason-installed servers and linters work correctly.

| Tool | Install command | Used by |
|------|----------------|---------|
| `gopls` | `go install golang.org/x/tools/gopls@latest` | LSP (Go) |
| `gofumpt` | `go install mvdan.cc/gofumpt@latest` | Formatter |
| `goimports` | `go install golang.org/x/tools/cmd/goimports@latest` | Formatter |
| `golangci-lint` | See [docs](https://golangci-lint.run/usage/install/) | Linter |
| `pyright` | `pip install pyright` | LSP (Python) |
| `black` | `pip install black` | Formatter |
| `isort` | `pip install isort` | Formatter |
| `flake8` | `pip install flake8` | Linter |
| `stylua` | `cargo install stylua` | Formatter (Lua) |
| `prettier` | `npm install -g prettier` | Formatter (JSON/YAML/MD) |
| `ripgrep` | OS package manager | Telescope live_grep |
| `fd` | OS package manager | Telescope file finder (optional) |

---

## 11. Adding a New Language

To add support for a new language (e.g., Rust), follow these steps:

**1. Add the LSP server to Mason auto-install** (`lua/plugins/lsp.lua`):

```lua
require("mason-lspconfig").setup({
    ensure_installed = {
        "gopls",
        "pyright",
        "lua_ls",
        "rust_analyzer",  -- ← add here
    },
})
```

**2. Configure the LSP server** (still in `lua/plugins/lsp.lua`):

```lua
require("lspconfig").rust_analyzer.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        ["rust-analyzer"] = { ... },
    },
})
```

**3. Add formatters** (`lua/plugins/editor.lua`, `conform` opts):

```lua
formatters_by_ft = {
    rust = { "rustfmt" },
    ...
}
```

**4. Add linters** (`lua/plugins/editor.lua`, `nvim-lint` config):

```lua
lint.linters_by_ft = {
    rust = { "clippy" },
    ...
}
```

**5. Add Treesitter grammar** (`lua/plugins/treesitter.lua`):

```lua
ensure_installed = {
    ...,
    "rust",
}
```

**6. Add filetype-specific auto-commands if needed** (`lua/core/autocmds.lua`):

```lua
autocmd("FileType", {
    pattern = "rust",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})
```

---

## 12. Troubleshooting

### Plugins not installing

Run `:Lazy sync` inside NeoVim, or delete `~/.local/share/nvim/lazy` and restart.

### LSP not starting

1. Run `:LspInfo` to see which servers are attached and their status.
2. Run `:Mason` to check if the server is installed.
3. Ensure the language binary is on your `$PATH` (e.g., `which gopls`).
4. For Go: make sure there is a `go.mod` file in your project root.
5. For Python: make sure your virtual environment is activated.

### Formatter not running

1. Run `:ConformInfo` to see which formatters are configured and whether they are available.
2. Ensure the formatter binary is on your `$PATH`.
3. Check `:messages` for error output after saving.

### Icons are missing or broken

Install a [Nerd Font](https://www.nerdfonts.com/) and set it as your terminal font.

### Treesitter highlighting looks wrong

Run `:TSUpdate` to rebuild parsers. If a specific language is broken, run `:TSInstall <lang>`.

### Which-key not showing groups

Ensure `<leader>` is set **before** lazy.nvim loads (it is set at the top of `keymaps.lua`, which is loaded before plugins via `init.lua`).

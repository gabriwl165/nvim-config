# AGENTS.md

Internal reference for AI assistants and contributors working on this Neovim configuration. The end-user guide lives in [README.md](README.md).

---

## 1. Project Overview

A modern Neovim setup built with **lazy.nvim**, targeting Go and Python development. Features LSP, completion, formatting, linting, fuzzy finding, Treesitter highlighting, and Claude Code CLI integration.

**Target Neovim version:** 0.11+ (uses `vim.lsp.config`, `vim.o.winborder`, mason-lspconfig 2.x).

---

## 2. Directory Structure

```
~/.config/nvim/
├── init.lua                  Entry point: requires `core` and `plugins`
├── lazy-lock.json            Reproducible plugin commits
└── lua/
    ├── core/
    │   ├── options.lua       Vim options (tabs, numbers, clipboard, folds...)
    │   ├── keymaps.lua       All key mappings (leader = <Space>)
    │   └── autocmds.lua      Auto-commands (format-on-save, filetype tweaks...)
    └── plugins/
        ├── init.lua          lazy.nvim bootstrap + spec import
        ├── ui.lua            Colorscheme, statusline, tree, gitsigns, fugitive, dashboard, notifier
        ├── editor.lua        Autopairs, surround, conform, nvim-lint, flash, trouble, todo
        ├── lsp.lua           Mason, nvim-lspconfig, gopls, pyright, lua_ls
        ├── completion.lua    nvim-cmp + LuaSnip + cmp-* sources
        ├── treesitter.lua    Syntax tree highlighting + textobjects
        ├── telescope.lua     Fuzzy finder + fzf-native + ui-select
        └── ai.lua            claudecode.nvim
```

`init.lua` simply does:

```lua
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("plugins")
```

---

## 3. Core Configuration

### `core/options.lua`

| Option | Value | Reason |
|--------|-------|--------|
| `number` + `relativenumber` | true | Absolute current line + relative for motions |
| `tabstop` / `shiftwidth` | 4 | Go and Python both use 4-wide indentation |
| `expandtab` | true (global) | Spaces by default; overridden to `false` for Go in `autocmds.lua` |
| `clipboard` | `unnamedplus` | Syncs the system clipboard with the `"` register |
| `undofile` | true | Persistent undo across sessions |
| `scrolloff` | 8 | Always keeps 8 lines visible above/below the cursor |
| `foldmethod` | `expr` (treesitter) | Code folding driven by the syntax tree |
| `colorcolumn` | 100 | Visual ruler; overridden to 120 for Go and 88 for Python |

### `core/keymaps.lua`

Sets `<Space>` as the leader key. All keymaps use `noremap = true, silent = true`. The full mapping table is in [README.md](README.md#key-bindings).

### `core/autocmds.lua`

| Group | Trigger | Effect |
|-------|---------|--------|
| `YankHighlight` | `TextYankPost` | Briefly highlights yanked text |
| `TrimWhitespace` | `BufWritePre *` | Removes trailing spaces on every save |
| `ResizeSplits` | `VimResized` | Re-equalises split sizes when terminal is resized |
| `GoSettings` | `FileType go` | Switches to real tabs (`expandtab=false`), 120-char ruler |
| `PythonSettings` | `FileType python` | Ensures 4-space indent, 88-char ruler (Black default) |
| `RestoreCursor` | `BufReadPost` | Jumps to last known cursor position when reopening a file |
| `CloseWithQ` | `FileType help,qf,...` | Lets you close auxiliary windows with just `q` |
| `AutoFormat` | `BufWritePre *.go,*.py` | Runs `conform.format({ lsp_format = "fallback" })` |

> **API note:** conform v8+ replaced `lsp_fallback = true` with `lsp_format = "fallback"`. Both `keymaps.lua` and `autocmds.lua` use the new form.

---

## 4. Plugin System

Managed by **[lazy.nvim](https://github.com/folke/lazy.nvim)** (cloned `--branch=stable` during bootstrap). Specs are split per-domain under `lua/plugins/` and aggregated via `spec` in `lua/plugins/init.lua`:

```lua
require("lazy").setup({
    spec = {
        { import = "plugins.ui" },
        { import = "plugins.editor" },
        { import = "plugins.lsp" },
        { import = "plugins.completion" },
        { import = "plugins.treesitter" },
        { import = "plugins.telescope" },
        { import = "plugins.ai" },
    },
    defaults = { version = false },
})
```

Lockfile: `lazy-lock.json` records the resolved branch + commit for each plugin.

---

## 5. Plugins Explained

### UI — `plugins/ui.lua`

| Plugin | Role |
|--------|------|
| `folke/tokyonight.nvim` | Colorscheme (`style = "night"`) |
| `nvim-lualine/lualine.nvim` | Status line (mode/branch/diff/diagnostics/filename/encoding/progress/location) |
| `akinsho/bufferline.nvim` | Buffer tabs with LSP diagnostic badges (`version = "*"`) |
| `nvim-tree/nvim-tree.lua` | File explorer (`<leader>e` toggle, `<leader>o` focus) |
| `lukas-reineke/indent-blankline.nvim` | Indent guides (uses `main = "ibl"` for v3) |
| `lewis6991/gitsigns.nvim` | Git diff signs + hunk-level operations (`<leader>gh*`) |
| `tpope/vim-fugitive` (+ `tpope/vim-rhubarb`) | Full Git wrapper. `:Git`/`:G` runs any git command; lazy-loaded via `cmd` and `keys`. rhubarb adds GitHub URL handling for `:GBrowse`. |
| `folke/which-key.nvim` | Keybinding popups (uses v3 `wk.add()` API for groups) |
| `folke/snacks.nvim` | Provides `dashboard` + `notifier` + `terminal` modules. `terminal` exposes `Snacks.terminal.toggle/open()` for persistent toggleable floating/docked terminals. |

### Editor — `plugins/editor.lua`

| Plugin | Role |
|--------|------|
| `windwp/nvim-autopairs` | Auto-close brackets/quotes (`check_ts = true` for treesitter awareness) |
| `kylechui/nvim-surround` | `ys/cs/ds` surround operators (`version = "*"`) |
| `folke/flash.nvim` | Enhanced jump motions (`s`/`S` overrides) |
| `folke/todo-comments.nvim` | Highlights `TODO`/`FIXME`/`HACK`/`NOTE`/`WARN` |
| `folke/trouble.nvim` | Pretty diagnostics list |
| `stevearc/conform.nvim` | Format orchestration (`format_after_save = { lsp_format = "fallback" }`) |
| `mfussenegger/nvim-lint` | Async linter runner on `BufEnter`/`BufWritePost`/`InsertLeave` |

> **Note on commenting:** `Comment.nvim` was removed because Neovim 0.10+ ships native `gc`/`gcc` operators via `vim.comment`. `nvim-ts-context-commentstring` is still loaded by `treesitter.lua` for embedded-language commentstring support.

### LSP — `plugins/lsp.lua`

Uses the **Neovim 0.11+ `vim.lsp.config` API**, not the older `lspconfig.<server>.setup()` pattern.

```lua
local servers = { "gopls", "pyright", "lua_ls" }

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = servers,
    -- We drive vim.lsp.enable ourselves below; this avoids mason-lspconfig
    -- routing through the legacy require('lspconfig').<server> framework,
    -- which errors hard on nvim-lspconfig v3.x.
    automatic_enable = false,
})

vim.o.winborder = "rounded"

local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("gopls", { settings = { gopls = { ... } } })
vim.lsp.config("pyright", { settings = { ... } })
vim.lsp.config("lua_ls", { settings = { Lua = { ... } } })

vim.lsp.enable(servers)
```

`folke/lazydev.nvim` (loaded `ft = "lua"`) replaces the deprecated `neodev.nvim` — provides Neovim API type hints to `lua_ls` when editing this config.

#### `gopls` settings (highlights)

| Setting | Effect |
|---------|--------|
| `gofumpt = true` | Stricter gofmt inside gopls |
| `staticcheck = true` | Extra static analyses |
| `analyses.{nilness, unusedparams, unusedwrite, useany}` | Enabled (note: `fieldalignment` removed upstream in gopls v0.17.0; use hover info instead) |
| `hints.*` | All inlay hint categories enabled |
| `usePlaceholders = true` | Function arg placeholders in completions |
| `completeUnimported = true` | Suggests symbols from unimported packages |
| `codelenses.{generate, run_govulncheck, test, tidy, upgrade_dependency}` | Enabled |

#### `pyright` settings

`typeCheckingMode = "basic"`, `autoSearchPaths = true`, `useLibraryCodeForTypes = true`, `autoImportCompletion = true`, `diagnosticMode = "openFilesOnly"`.

#### `lua_ls` settings

`workspace.checkThirdParty = false`, `telemetry.enable = false`, `completion.callSnippet = "Replace"`. Combined with `lazydev.nvim`, no manual `runtime.path` munging is needed.

#### LspAttach keymaps

Set inside an `LspAttach` autocmd (buffer-local). See `lua/plugins/lsp.lua` lines 52-70.

### Completion — `plugins/completion.lua`

`hrsh7th/nvim-cmp` engine with sources (priority order):

| Priority | Source |
|----------|--------|
| 1000 | `nvim_lsp` (via `cmp-nvim-lsp`) |
| 750 | `luasnip` (via `cmp_luasnip`) |
| 500 | `buffer` (via `cmp-buffer`) |
| 250 | `path` (via `cmp-path`) |

`cmp-cmdline` provides `:` and `/` `?` completion. `LuaSnip` is pinned to `version = "v2.*"` with `build = "make install_jsregexp"`. `friendly-snippets` is loaded via `require("luasnip.loaders.from_vscode").lazy_load()`.

> **Future migration:** `nvim-cmp` and its `cmp-*` sources are in maintenance mode; `Saghen/blink.cmp` is the recommended successor. Not yet migrated.

### Treesitter — `plugins/treesitter.lua`

`nvim-treesitter/nvim-treesitter` (`branch = "master"`, `build = ":TSUpdate"`) with `nvim-treesitter-textobjects` for semantic select/move/swap operators (`af`/`if`, `ac`/`ic`, `aa`/`ia`, `ab`/`ib`, `]f`/`[f`, etc.).

Pre-installed grammars: `go`, `gomod`, `gosum`, `gowork`, `python`, `lua`, `vim`, `vimdoc`, `bash`, `json`, `yaml`, `toml`, `markdown`, `markdown_inline`, `regex`, `dockerfile`, `gitignore`, `sql`. `auto_install = true` lazily installs missing grammars on first file open.

### Telescope — `plugins/telescope.lua`

`nvim-telescope/telescope.nvim` tracking `master` (the project stopped tagging after `0.1.8`). Loads `telescope-fzf-native.nvim` (compiled C extension via `make`) and `telescope-ui-select.nvim` (replaces `vim.ui.select` for code actions, etc.).

Default insert-mode mappings inside Telescope: `<C-j>`/`<C-k>` next/prev, `<C-q>` send to qflist, `<Esc>` close.

### AI — `plugins/ai.lua`

`coder/claudecode.nvim` integrates the Claude Code CLI via the same protocol as the official VS Code extension. Depends on `folke/snacks.nvim`. Auth via `claude login` (no API key). Keymaps: `<leader>ac` toggle terminal, `<leader>as` send visual selection, `<leader>aS` send buffer.

---

## 6. Conventions

- **Per-language autocmds** live in `core/autocmds.lua` (use `vim.opt_local.*`).
- **Per-language keymaps** use a `<leader>{lang-prefix}` pattern: `<leader>go*` for Go, `<leader>py*` for Python, `<leader>a*` for AI.
- **Run / test / build commands** use `Snacks.terminal.open({ "cmd", "args" })` — opens a transient floating terminal that auto-disposes on close, keeps the screen usable while logs stream. Never blocking `:!`.
- **Persistent terminals** use `Snacks.terminal.toggle()` keyed by direction (bottom/right/float). Same keymap reopens the same terminal with state intact.
- `<Esc><Esc>` exits terminal-insert; `<C-/>` toggles float terminal from any mode.
- **Plugin specs** are grouped by domain, never by language. A new language touches multiple files (LSP, conform, lint, treesitter, autocmds).
- **Format-on-save** is gated through conform with `lsp_format = "fallback"`. Direct `vim.lsp.buf.format()` is not used.
- **No direct database/network calls** from plugin specs. All side effects belong in `config = function() ... end` blocks evaluated by lazy.

---

## 7. Adding a New Language

Example: Rust.

**1. LSP server** — `lua/plugins/lsp.lua`:

```lua
require("mason-lspconfig").setup({
    ensure_installed = { "gopls", "pyright", "lua_ls", "rust_analyzer" },
    automatic_enable = false,
})

vim.lsp.config("rust_analyzer", {
    settings = { ["rust-analyzer"] = { ... } },
})
```

**2. Formatter** — `lua/plugins/editor.lua` (`conform` opts):

```lua
formatters_by_ft = {
    rust = { "rustfmt" },
    ...
}
```

**3. Linter** — `lua/plugins/editor.lua` (`nvim-lint` config):

```lua
lint.linters_by_ft = {
    rust = { "clippy" },
    ...
}
```

**4. Treesitter grammar** — `lua/plugins/treesitter.lua`:

```lua
ensure_installed = { ..., "rust" }
```

**5. Filetype options** — `lua/core/autocmds.lua`:

```lua
autocmd("FileType", {
    pattern = "rust",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})
```

**6. Format-on-save trigger** — extend the `AutoFormat` autocmd pattern in `core/autocmds.lua`.

---

## 8. Maintenance Notes

- `lazy-lock.json` is auto-rewritten by `:Lazy sync`. Don't hand-edit unless removing entries for plugins permanently dropped from the spec.
- Mason packages are stored under `~/.local/share/nvim/mason/`. To force a clean reinstall: `:MasonUninstall <pkg>` then `:MasonInstall <pkg>`.
- Treesitter parsers are stored under `~/.local/share/nvim/lazy/nvim-treesitter/parser/`. After a Neovim major version bump, run `:TSUpdate`.
- When upgrading conform, watch for further deprecations to `lsp_format` / `format_after_save` semantics.

---

## 9. Known Out-of-Scope Migrations

| Migration | Status | Reason |
|-----------|--------|--------|
| `nvim-cmp` → `blink.cmp` | Deferred | Touches 6 plugin specs + entire `completion.lua`; do in a dedicated session |

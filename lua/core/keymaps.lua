vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = function(mode, lhs, rhs, desc, extra)
    local opts = vim.tbl_extend("force", { noremap = true, silent = true, desc = desc }, extra or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- ─── General ────────────────────────────────────────────────────────────────
map("n", "<leader>w",  "<cmd>w<cr>",   "Save file")
map("n", "<leader>q",  "<cmd>q<cr>",   "Quit")
map("n", "<leader>Q",  "<cmd>qa!<cr>", "Quit all (force)")
map("n", "<Esc>",      "<cmd>nohlsearch<cr>", "Clear search highlight")

-- ─── Window navigation ──────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", "Move to left window")
map("n", "<C-j>", "<C-w>j", "Move to lower window")
map("n", "<C-k>", "<C-w>k", "Move to upper window")
map("n", "<C-l>", "<C-w>l", "Move to right window")

-- ─── Resize windows ─────────────────────────────────────────────────────────
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          "Increase height")
map("n", "<C-Down>",  "<cmd>resize -2<cr>",           "Decrease height")
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>",  "Decrease width")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>",  "Increase width")

-- ─── Buffer navigation ──────────────────────────────────────────────────────
map("n", "<S-l>",       "<cmd>bnext<cr>",     "Next buffer")
map("n", "<S-h>",       "<cmd>bprevious<cr>", "Previous buffer")
map("n", "<leader>bd",  "<cmd>bdelete<cr>",   "Delete buffer")

-- ─── Indentation (keep selection) ───────────────────────────────────────────
map("v", "<", "<gv", "Dedent")
map("v", ">", ">gv", "Indent")

-- ─── Move lines ─────────────────────────────────────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<cr>==",  "Move line down")
map("n", "<A-k>", "<cmd>m .-2<cr>==",  "Move line up")
map("v", "<A-j>", ":m '>+1<cr>gv=gv", "Move selection down")
map("v", "<A-k>", ":m '<-2<cr>gv=gv", "Move selection up")

-- ─── Splits ─────────────────────────────────────────────────────────────────
map("n", "<leader>sv", "<cmd>vsplit<cr>", "Vertical split")
map("n", "<leader>sh", "<cmd>split<cr>",  "Horizontal split")
map("n", "<leader>sx", "<cmd>close<cr>",  "Close split")

-- ─── File Explorer ──────────────────────────────────────────────────────────
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", "Toggle file explorer")
map("n", "<leader>o", "<cmd>NvimTreeFocus<cr>",  "Focus file explorer")

-- ─── Telescope ──────────────────────────────────────────────────────────────
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",  "Find files")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",   "Live grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",     "Find buffers")
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",   "Help tags")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>",    "Recent files")
map("n", "<leader>fs", "<cmd>Telescope grep_string<cr>", "Grep word under cursor")
map("n", "<leader>ft", "<cmd>TodoTelescope<cr>",         "Find TODOs")

-- ─── LSP (generic) ──────────────────────────────────────────────────────────
map("n", "<leader>lf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, "Format file")
map("n", "<leader>lm", "<cmd>Mason<cr>",   "Mason package manager")
map("n", "<leader>li", "<cmd>LspInfo<cr>", "LSP info")

-- ─── Diagnostics ────────────────────────────────────────────────────────────
map("n", "<leader>d", vim.diagnostic.open_float, "Open diagnostic float")
map("n", "[d",        vim.diagnostic.goto_prev,  "Previous diagnostic")
map("n", "]d",        vim.diagnostic.goto_next,  "Next diagnostic")

-- ─── Trouble ────────────────────────────────────────────────────────────────
map("n", "<leader>xx", "<cmd>TroubleToggle<cr>",                          "Toggle Trouble")
map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",    "Workspace diagnostics")
map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",     "Document diagnostics")

-- ─── Terminal (Snacks.terminal — toggleable, persistent) ───────────────────
-- <C-/> toggles a floating scratch terminal (process keeps running when hidden).
-- <leader>t{t,v,f} are direction-specific persistent terminals.
map({ "n", "t" }, "<C-/>", function() Snacks.terminal.toggle() end, "Terminal: toggle (float)")

map("n", "<leader>tt", function()
    Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 0.35 } })
end, "Terminal: bottom (toggle)")

map("n", "<leader>tv", function()
    Snacks.terminal.toggle(nil, { win = { position = "right", width = 0.45 } })
end, "Terminal: right (toggle)")

map("n", "<leader>tf", function() Snacks.terminal.toggle() end, "Terminal: float (toggle)")

-- Inside any terminal: double-Esc leaves insert; <C-hjkl> jumps between windows.
map("t", "<Esc><Esc>", "<C-\\><C-n>",        "Terminal: leave insert mode")
map("t", "<C-h>",      "<C-\\><C-n><C-w>h", "Terminal: window left")
map("t", "<C-j>",      "<C-\\><C-n><C-w>j", "Terminal: window below")
map("t", "<C-k>",      "<C-\\><C-n><C-w>k", "Terminal: window above")
map("t", "<C-l>",      "<C-\\><C-n><C-w>l", "Terminal: window right")

-- ─── Tabs (whole layouts) ───────────────────────────────────────────────────
-- <leader><Tab>… works only in normal mode (because <leader> is <Space>, which
-- gets swallowed by terminal-insert mode). For switching tabs from inside a
-- running terminal, use the <A-h>/<A-l> bindings below — they work everywhere:
-- normal, insert, visual, and terminal-insert mode.
map("n", "<leader><Tab>n", "<cmd>tabnew<cr>",     "Tab: new")
map("n", "<leader><Tab>x", "<cmd>tabclose<cr>",   "Tab: close")
map("n", "<leader><Tab>l", "<cmd>tabnext<cr>",    "Tab: next")
map("n", "<leader><Tab>h", "<cmd>tabprevious<cr>","Tab: previous")

-- Universal tab-switching that works in n / i / v / t modes — including from
-- a running terminal opened by <leader>gor / pyr. We bind BOTH:
--   * <C-PageUp>/<C-PageDown> — universally passed by all terminal emulators
--   * <A-h>/<A-l>/<A-t>/<A-w> — ergonomic, but require Option/Alt to be
--     forwarded by your terminal (on macOS Terminal.app: Settings → Profiles
--     → Keyboard → "Use Option as Meta key"; on iTerm2: Profiles → Keys →
--     Left Option = Esc+).
-- In terminal mode we exit terminal-insert first via <C-\><C-n> so the
-- command runs in normal mode.
local tab_next  = "<cmd>tabnext<cr>"
local tab_prev  = "<cmd>tabprevious<cr>"
local tab_new   = "<cmd>tabnew<cr>"
local tab_close = "<cmd>tabclose<cr>"

map({ "n", "i", "v" }, "<C-PageDown>", tab_next,  "Tab: next (any mode)")
map({ "n", "i", "v" }, "<C-PageUp>",   tab_prev,  "Tab: previous (any mode)")
map({ "n", "i", "v" }, "<A-l>",        tab_next,  "Tab: next (any mode)")
map({ "n", "i", "v" }, "<A-h>",        tab_prev,  "Tab: previous (any mode)")
map({ "n", "i", "v" }, "<A-t>",        tab_new,   "Tab: new (any mode)")
map({ "n", "i", "v" }, "<A-w>",        tab_close, "Tab: close (any mode)")

map("t", "<C-PageDown>", "<C-\\><C-n>" .. tab_next,  "Tab: next (from terminal)")
map("t", "<C-PageUp>",   "<C-\\><C-n>" .. tab_prev,  "Tab: previous (from terminal)")
map("t", "<A-l>",        "<C-\\><C-n>" .. tab_next,  "Tab: next (from terminal)")
map("t", "<A-h>",        "<C-\\><C-n>" .. tab_prev,  "Tab: previous (from terminal)")
map("t", "<A-t>",        "<C-\\><C-n>" .. tab_new,   "Tab: new (from terminal)")
map("t", "<A-w>",        "<C-\\><C-n>" .. tab_close, "Tab: close (from terminal)")

-- ─── Run / test / build helpers ─────────────────────────────────────────────
-- Long-running commands (gor, pyr) use a bottom DOCKED terminal so you can press
-- <C-k> to jump back to your code while the process keeps running.
-- Quick commands (test/build/tidy) use a FLOATING terminal that auto-disposes.
local dock_bottom = { win = { position = "bottom", height = 0.35 } }

map("n", "<leader>gor", function() Snacks.terminal.open({ "go", "run", vim.fn.expand("%") }, dock_bottom) end, "Go: run current file")
map("n", "<leader>got", function() Snacks.terminal.open({ "go", "test", "./..." })                       end, "Go: test all packages")
map("n", "<leader>gob", function() Snacks.terminal.open({ "go", "build", "./..." })                      end, "Go: build all packages")
map("n", "<leader>goi", function() Snacks.terminal.open({ "go", "mod", "tidy" })                         end, "Go: tidy modules")

map("n", "<leader>pyr", function() Snacks.terminal.open({ "python3", vim.fn.expand("%") }, dock_bottom) end, "Python: run current file")
map("n", "<leader>pyt", function() Snacks.terminal.open({ "python3", "-m", "pytest" })                  end, "Python: run pytest")
map("n", "<leader>pyv", "<cmd>!python3 -m venv .venv<cr>",                                                    "Python: create venv")

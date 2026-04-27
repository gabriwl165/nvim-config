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

-- ─── Terminal ───────────────────────────────────────────────────────────────
-- Open terminals in splits so they don't eat the whole screen.
map("n", "<leader>tt", "<cmd>botright 12split | terminal<cr>",  "Terminal: horizontal split")
map("n", "<leader>tv", "<cmd>botright vsplit | terminal<cr>",   "Terminal: vertical split")
map("n", "<leader>tf", "<cmd>tabnew | terminal<cr>",            "Terminal: new tab")

-- Exit terminal-insert mode with double Esc; window nav still works inside terminals.
map("t", "<Esc><Esc>", "<C-\\><C-n>",            "Terminal: leave insert mode")
map("t", "<C-h>",      "<C-\\><C-n><C-w>h",     "Terminal: window left")
map("t", "<C-j>",      "<C-\\><C-n><C-w>j",     "Terminal: window below")
map("t", "<C-k>",      "<C-\\><C-n><C-w>k",     "Terminal: window above")
map("t", "<C-l>",      "<C-\\><C-n><C-w>l",     "Terminal: window right")

-- ─── Tabs (whole layouts) ───────────────────────────────────────────────────
map("n", "<leader><Tab>n", "<cmd>tabnew<cr>",     "Tab: new")
map("n", "<leader><Tab>x", "<cmd>tabclose<cr>",   "Tab: close")
map("n", "<leader><Tab>l", "<cmd>tabnext<cr>",    "Tab: next")
map("n", "<leader><Tab>h", "<cmd>tabprevious<cr>","Tab: previous")

-- ─── Go ─────────────────────────────────────────────────────────────────────
-- Use a bottom terminal split so logs don't take over the screen.
-- Press <Esc><Esc> to leave insert, then `<leader>sx` to close the split.
map("n", "<leader>gor", "<cmd>botright 15split | terminal go run %<cr>",       "Go: run current file")
map("n", "<leader>got", "<cmd>botright 15split | terminal go test ./...<cr>",  "Go: test all packages")
map("n", "<leader>gob", "<cmd>botright 15split | terminal go build ./...<cr>", "Go: build all packages")
map("n", "<leader>goi", "<cmd>botright 15split | terminal go mod tidy<cr>",    "Go: tidy modules")

-- ─── Python ─────────────────────────────────────────────────────────────────
map("n", "<leader>pyr", "<cmd>botright 15split | terminal python3 %<cr>",           "Python: run current file")
map("n", "<leader>pyt", "<cmd>botright 15split | terminal python3 -m pytest<cr>",   "Python: run pytest")
map("n", "<leader>pyv", "<cmd>!python3 -m venv .venv<cr>",                          "Python: create venv")

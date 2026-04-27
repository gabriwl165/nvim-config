local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
    group = "YankHighlight",
    callback = function()
        vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
    end,
})

-- Remove trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
    group = "TrimWhitespace",
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

-- Auto-resize splits when the terminal window is resized
augroup("ResizeSplits", { clear = true })
autocmd("VimResized", {
    group = "ResizeSplits",
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Go: use real tabs (gofmt convention)
augroup("GoSettings", { clear = true })
autocmd("FileType", {
    group = "GoSettings",
    pattern = "go",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.colorcolumn = "120"
    end,
})

-- Python: PEP 8 — 4 spaces, 88-char column (Black default)
augroup("PythonSettings", { clear = true })
autocmd("FileType", {
    group = "PythonSettings",
    pattern = "python",
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.colorcolumn = "88"
    end,
})

-- Restore last cursor position
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
    group = "RestoreCursor",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Close certain filetypes with just <q>
augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
    group = "CloseWithQ",
    pattern = { "help", "lspinfo", "man", "notify", "qf", "startuptime", "tsplayground" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- Auto-format on save via conform (triggered from plugins/editor.lua)
augroup("AutoFormat", { clear = true })
autocmd("BufWritePre", {
    group = "AutoFormat",
    pattern = { "*.go", "*.py" },
    callback = function()
        local ok, conform = pcall(require, "conform")
        if ok then
            conform.format({ async = false, lsp_fallback = true, timeout_ms = 1000 })
        end
    end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins.ui" },
        { import = "plugins.editor" },
        { import = "plugins.lsp" },
        { import = "plugins.completion" },
        { import = "plugins.treesitter" },
        { import = "plugins.telescope" },
        { import = "plugins.debug" },
        { import = "plugins.ai" },
    },
    defaults = {
        version = false,
    },
    install = {
        colorscheme = { "tokyonight", "habamax" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    performance = {
        rtp = {
            disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
        },
    },
})

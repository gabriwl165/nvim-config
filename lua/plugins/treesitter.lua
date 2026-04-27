return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "TSUpdate", "TSUpdateSync", "TSInstall", "TSInstallSync", "TSInstallInfo", "TSUninstall", "TSBufEnable", "TSBufDisable", "TSEnable", "TSDisable", "TSModuleInfo" },
        dependencies = {
            -- Stay on master to match nvim-treesitter master (legacy line).
            -- The `main` branch of textobjects targets the async rewrite of
            -- nvim-treesitter `main`; switching only one side breaks the API.
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    -- Go
                    "go", "gomod", "gosum", "gowork",
                    -- Python
                    "python",
                    -- Lua / Vim
                    "lua", "vim", "vimdoc",
                    -- Shell / Config
                    "bash", "json", "yaml", "toml",
                    "markdown", "markdown_inline",
                    "regex", "dockerfile", "gitignore", "sql",
                },
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection  = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["ab"] = "@block.outer",
                            ["ib"] = "@block.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]f"] = "@function.outer",
                            ["]c"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]F"] = "@function.outer",
                            ["]C"] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[f"] = "@function.outer",
                            ["[c"] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[F"] = "@function.outer",
                            ["[C"] = "@class.outer",
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next     = { ["<leader>na"] = "@parameter.inner" },
                        swap_previous = { ["<leader>pa"] = "@parameter.inner" },
                    },
                },
            })

            require("ts_context_commentstring").setup({ enable_autocmd = false })
        end,
    },
}

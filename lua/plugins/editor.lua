return {
    -- ─── Autopairs ────────────────────────────────────────────────────────────
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
            check_ts = true,
            ts_config = { lua = { "string" } },
        },
    },

    -- ─── Comments ─────────────────────────────────────────────────────────────
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
        config = function()
            require("Comment").setup({
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },

    -- ─── Surround ─────────────────────────────────────────────────────────────
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },

    -- ─── Jump motions (replaces s/S) ──────────────────────────────────────────
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,            desc = "Flash jump" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,       desc = "Flash treesitter" },
        },
    },

    -- ─── TODO / FIXME / HACK comments ────────────────────────────────────────
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },

    -- ─── Diagnostics list ─────────────────────────────────────────────────────
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },

    -- ─── Formatting ───────────────────────────────────────────────────────────
    -- conform runs format-on-save; the autocmds.lua hook calls it for .go/.py.
    -- You can also trigger it manually with <leader>lf.
    {
        "stevearc/conform.nvim",
        cmd = "ConformInfo",
        opts = {
            formatters_by_ft = {
                go     = { "gofumpt", "goimports" },
                python = { "isort", "black" },
                lua    = { "stylua" },
                json   = { "prettier" },
                yaml   = { "prettier" },
                markdown = { "prettier" },
            },
            -- format_on_save is handled in autocmds.lua for fine-grained control
            format_after_save = {
                lsp_fallback = true,
            },
        },
    },

    -- ─── Linting ──────────────────────────────────────────────────────────────
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                go     = { "golangcilint" },
                python = { "flake8" },
            }

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}

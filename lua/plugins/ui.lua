return {
    -- ─── Colorscheme ──────────────────────────────────────────────────────────
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
            transparent = false,
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
            },
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd("colorscheme tokyonight")
        end,
    },

    -- ─── Status line ──────────────────────────────────────────────────────────
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                icons_enabled = true,
                theme = "tokyonight",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                globalstatus = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },

    -- ─── Buffer tabs ──────────────────────────────────────────────────────────
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                mode = "buffers",
                separator_style = "slant",
                show_buffer_close_icons = true,
                show_close_icon = false,
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(_, _, diag)
                    local icons = { error = " ", warning = " " }
                    local ret = (diag.error and icons.error .. diag.error .. " " or "")
                        .. (diag.warning and icons.warning .. diag.warning or "")
                    return vim.trim(ret)
                end,
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        highlight = "Directory",
                        separator = true,
                    },
                },
            },
        },
    },

    -- ─── File explorer ────────────────────────────────────────────────────────
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            view = { width = 30, side = "left" },
            renderer = {
                group_empty = true,
                icons = {
                    show = { file = true, folder = true, folder_arrow = true, git = true },
                },
            },
            filters = { dotfiles = false },
            git = { enable = true, ignore = false },
        },
    },

    -- ─── Indent guides ────────────────────────────────────────────────────────
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "│" },
            scope = { enabled = true },
        },
    },

    -- ─── Git signs ────────────────────────────────────────────────────────────
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local m = function(l, r, desc)
                    vim.keymap.set("n", l, r, { buffer = bufnr, desc = desc })
                end
                m("]c",          gs.next_hunk,                         "Git: next hunk")
                m("[c",          gs.prev_hunk,                         "Git: prev hunk")
                m("<leader>ghs", gs.stage_hunk,                        "Git: stage hunk")
                m("<leader>ghr", gs.reset_hunk,                        "Git: reset hunk")
                m("<leader>ghS", gs.stage_buffer,                      "Git: stage buffer")
                m("<leader>ghR", gs.reset_buffer,                      "Git: reset buffer")
                m("<leader>ghp", gs.preview_hunk,                      "Git: preview hunk")
                m("<leader>ghb", function() gs.blame_line({ full = true }) end, "Git: blame line")
                m("<leader>ghd", gs.diffthis,                          "Git: diff this")
            end,
        },
    },

    -- ─── Git wrapper (fugitive) ───────────────────────────────────────────────
    -- :Git / :G runs any git command. Lazy-loaded by command and keys.
    -- vim-rhubarb adds GitHub URL support to :GBrowse.
    {
        "tpope/vim-fugitive",
        dependencies = { "tpope/vim-rhubarb" },
        cmd = {
            "Git", "G",
            "Gdiffsplit", "Gvdiffsplit",
            "Gedit", "Gsplit", "Gread", "Gwrite",
            "Ggrep", "Glgrep",
            "GMove", "GRename", "GDelete", "GRemove",
            "GBrowse",
        },
        keys = {
            { "<leader>gs", "<cmd>Git<cr>",                 desc = "Git: status (summary)" },
            { "<leader>gc", "<cmd>Git commit<cr>",          desc = "Git: commit" },
            { "<leader>gp", "<cmd>Git pull<cr>",            desc = "Git: pull" },
            { "<leader>gP", "<cmd>Git push<cr>",            desc = "Git: push" },
            { "<leader>gB", "<cmd>Git blame<cr>",           desc = "Git: blame buffer" },
            { "<leader>gd", "<cmd>Gdiffsplit<cr>",          desc = "Git: diff against index" },
            { "<leader>gl", "<cmd>Git log --oneline<cr>",   desc = "Git: log (oneline)" },
            { "<leader>gw", "<cmd>Gwrite<cr>",              desc = "Git: stage current file" },
            { "<leader>gr", "<cmd>Gread<cr>",               desc = "Git: checkout buffer" },
            { "<leader>gO", "<cmd>GBrowse<cr>",             desc = "Git: open in browser" },
            { "<leader>gO", ":GBrowse<cr>", mode = "v",     desc = "Git: open selection in browser" },
        },
    },

    -- ─── Key hints ────────────────────────────────────────────────────────────
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
            wk.add({
                { "<leader>f",   group = "Find (Telescope)" },
                { "<leader>g",   group = "Git" },
                { "<leader>gh",  group = "Git hunks" },
                { "<leader>l",   group = "LSP" },
                { "<leader>s",   group = "Splits" },
                { "<leader>b",   group = "Buffers" },
                { "<leader>x",   group = "Trouble / Diagnostics" },
                { "<leader>go",  group = "Go" },
                { "<leader>py",  group = "Python" },
            })
        end,
    },

    -- ─── Snacks (dashboard + notifier) ────────────────────────────────────────
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            notifier = {
                enabled = true,
                timeout = 3000,
            },
            dashboard = {
                enabled = true,
                preset = {
                    header = table.concat({
                        "",
                        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                        "",
                    }, "\n"),
                    keys = {
                        { icon = " ", key = "f", desc = "Find file",    action = ":Telescope find_files" },
                        { icon = " ", key = "e", desc = "New file",     action = ":ene | startinsert" },
                        { icon = " ", key = "r", desc = "Recent files", action = ":Telescope oldfiles" },
                        { icon = " ", key = "g", desc = "Find text",    action = ":Telescope live_grep" },
                        { icon = " ", key = "c", desc = "Config",       action = ":e $MYVIMRC" },
                        { icon = "󰒲 ", key = "l", desc = "Lazy",         action = ":Lazy" },
                        { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
                    },
                },
            },
        },
    },
}

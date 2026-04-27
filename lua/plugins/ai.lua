-- Requires: export ANTHROPIC_API_KEY="sk-ant-..."  in your shell profile
return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        version = false,
        build = "make",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            {
                -- Paste images into the chat (optional)
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = { insert_mode = true },
                    },
                },
            },
            {
                -- Render markdown properly inside Avante's chat window
                "MeanderingProgrammer/render-markdown.nvim",
                opts = { file_types = { "markdown", "Avante" } },
                ft = { "markdown", "Avante" },
            },
        },
        opts = {
            -- Use Claude as the AI provider
            provider = "claude",
            claude = {
                endpoint = "https://api.anthropic.com",
                model = "claude-sonnet-4-5",
                timeout = 30000,
                temperature = 0,
                max_tokens = 8096,
            },
            behaviour = {
                auto_suggestions = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
            },
            -- Sidebar appears on the right, 40% width
            windows = {
                position = "right",
                wrap = true,
                width = 40,
                sidebar_header = {
                    enabled = true,
                    align = "center",
                    rounded = true,
                },
            },
            -- Diff view colours
            highlights = {
                diff = { current = "DiffText", incoming = "DiffAdd" },
            },
            diff = {
                autojump = true,
                list_opener = "copen",
            },
            -- Key mappings used inside the Avante sidebar/diff view
            mappings = {
                diff = {
                    ours    = "co",
                    theirs  = "ct",
                    both    = "cb",
                    next    = "]x",
                    prev    = "[x",
                },
                submit = {
                    normal = "<CR>",
                    insert = "<C-s>",
                },
                sidebar = {
                    close = "q",
                    close_from_input = "<C-q>",
                },
            },
        },
    },
}

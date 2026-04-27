return {
    -- ─── Mason: LSP / linter / formatter installer ────────────────────────────
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
    },

    -- ─── LSP Configuration (Neovim 0.11+ vim.lsp.config API) ─────────────────
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "folke/lazydev.nvim",
        },
        config = function()
            -- Mason must be set up before mason-lspconfig so its bin/ is on PATH
            require("mason").setup()

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "gopls",   -- Go
                    "pyright", -- Python
                    "lua_ls",  -- Lua
                },
                -- mason-lspconfig 2.x: auto-enables installed servers via vim.lsp.enable()
                automatic_enable = true,
            })

            -- Rounded borders for floating LSP windows (Neovim 0.11+ global option)
            vim.o.winborder = "rounded"

            vim.diagnostic.config({
                virtual_text = { prefix = "●" },
                severity_sort = true,
                float = { source = true, border = "rounded" },
            })

            -- LSP keymaps fire on attach to any buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local m = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    m("gd",         vim.lsp.buf.definition,       "Go to definition")
                    m("gD",         vim.lsp.buf.declaration,      "Go to declaration")
                    m("gr",         vim.lsp.buf.references,       "Go to references")
                    m("gI",         vim.lsp.buf.implementation,   "Go to implementation")
                    m("gy",         vim.lsp.buf.type_definition,  "Go to type definition")
                    m("K",          vim.lsp.buf.hover,            "Hover documentation")
                    m("<C-k>",      vim.lsp.buf.signature_help,   "Signature help")
                    m("<leader>la", vim.lsp.buf.code_action,      "Code action")
                    m("<leader>lr", vim.lsp.buf.rename,           "Rename symbol")
                    m("<leader>ls", vim.lsp.buf.document_symbol,  "Document symbols")
                    m("<leader>lS", vim.lsp.buf.workspace_symbol, "Workspace symbols")
                end,
            })

            -- Default capabilities for every server (nvim-cmp completion support)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            vim.lsp.config("*", { capabilities = capabilities })

            -- ── Go (gopls) ────────────────────────────────────────────────────
            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        gofumpt = true,
                        codelenses = {
                            generate = true,
                            run_govulncheck = true,
                            test = true,
                            tidy = true,
                            upgrade_dependency = true,
                        },
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                        analyses = {
                            nilness = true,
                            unusedparams = true,
                            unusedwrite = true,
                            useany = true,
                        },
                        usePlaceholders = true,
                        completeUnimported = true,
                        staticcheck = true,
                        semanticTokens = true,
                        directoryFilters = {
                            "-.git", "-.vscode", "-.idea", "-node_modules", "-vendor",
                        },
                    },
                },
            })

            -- ── Python (pyright) ──────────────────────────────────────────────
            vim.lsp.config("pyright", {
                settings = {
                    pyright = {
                        autoImportCompletion = true,
                    },
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = "openFilesOnly",
                            useLibraryCodeForTypes = true,
                            typeCheckingMode = "basic",
                        },
                    },
                },
            })

            -- ── Lua (lua_ls) ──────────────────────────────────────────────────
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                        completion = { callSnippet = "Replace" },
                    },
                },
            })
        end,
    },

    -- lazydev: Neovim API type hints for lua_ls (replaces deprecated neodev)
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}

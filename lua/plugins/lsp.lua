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

    -- ─── LSP Configuration ────────────────────────────────────────────────────
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "folke/neodev.nvim",
        },
        config = function()
            -- neodev must be set up before lspconfig.lua_ls
            require("neodev").setup()

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "gopls",    -- Go
                    "pyright",  -- Python
                    "lua_ls",   -- Lua (for editing this config)
                },
                automatic_installation = true,
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Rounded borders everywhere
            local border = "rounded"
            vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
                vim.lsp.handlers.hover(err, result, ctx, vim.tbl_extend("force", config or {}, { border = border }))
            end
            vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
                vim.lsp.handlers.signature_help(err, result, ctx, vim.tbl_extend("force", config or {}, { border = border }))
            end

            vim.diagnostic.config({
                virtual_text = { prefix = "●" },
                severity_sort = true,
                float = { source = "always", border = border },
            })

            -- Keymaps applied when any LSP attaches to a buffer
            local on_attach = function(_, bufnr)
                local m = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                end

                m("gd",          vim.lsp.buf.definition,      "Go to definition")
                m("gD",          vim.lsp.buf.declaration,     "Go to declaration")
                m("gr",          vim.lsp.buf.references,      "Go to references")
                m("gI",          vim.lsp.buf.implementation,  "Go to implementation")
                m("gy",          vim.lsp.buf.type_definition, "Go to type definition")
                m("K",           vim.lsp.buf.hover,           "Hover documentation")
                m("<C-k>",       vim.lsp.buf.signature_help,  "Signature help")
                m("<leader>la",  vim.lsp.buf.code_action,     "Code action")
                m("<leader>lr",  vim.lsp.buf.rename,          "Rename symbol")
                m("<leader>ls",  vim.lsp.buf.document_symbol, "Document symbols")
                m("<leader>lS",  vim.lsp.buf.workspace_symbol,"Workspace symbols")
            end

            -- ── Go (gopls) ────────────────────────────────────────────────────
            require("lspconfig").gopls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
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
                            fieldalignment = true,
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
            require("lspconfig").pyright.setup({
                capabilities = capabilities,
                on_attach = on_attach,
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

            -- ── Lua (lua_ls) — for editing this config ────────────────────────
            require("lspconfig").lua_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
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

    -- neodev must be in the plugin list so lazy can install it
    { "folke/neodev.nvim", opts = {} },
}

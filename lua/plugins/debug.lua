return {
    -- ─── DAP core ─────────────────────────────────────────────────────────────
    -- Debug Adapter Protocol client. Loads on first debug keypress so it does
    -- not impact startup. Built-in default configurations are provided by
    -- nvim-dap-go and nvim-dap-python so debugging works in any project; an
    -- optional .vscode/launch.json is auto-loaded on top when present.
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
            "jay-babu/mason-nvim-dap.nvim",
            "williamboman/mason.nvim",
        },
        keys = {
            { "<F5>",        function() require("dap").continue() end,             desc = "Debug: continue / start" },
            { "<F10>",       function() require("dap").step_over() end,            desc = "Debug: step over" },
            { "<F11>",       function() require("dap").step_into() end,            desc = "Debug: step into" },
            { "<F12>",       function() require("dap").step_out() end,             desc = "Debug: step out" },
            { "<F9>",        function() require("dap").toggle_breakpoint() end,    desc = "Debug: toggle breakpoint" },
            { "<leader>Dc",  function() require("dap").continue() end,             desc = "Debug: continue / start" },
            { "<leader>Dn",  function() require("dap").step_over() end,            desc = "Debug: step over (next)" },
            { "<leader>Di",  function() require("dap").step_into() end,            desc = "Debug: step into" },
            { "<leader>Do",  function() require("dap").step_out() end,             desc = "Debug: step out" },
            { "<leader>Db",  function() require("dap").toggle_breakpoint() end,    desc = "Debug: toggle breakpoint" },
            { "<leader>DB",  function()
                vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
                    if cond and cond ~= "" then
                        require("dap").set_breakpoint(cond)
                    end
                end)
            end, desc = "Debug: conditional breakpoint" },
            { "<leader>Dl",  function() require("dap").run_last() end,             desc = "Debug: run last" },
            { "<leader>Dr",  function() require("dap").repl.toggle() end,          desc = "Debug: toggle REPL" },
            { "<leader>Dq",  function() require("dap").terminate() end,            desc = "Debug: terminate session" },
            { "<leader>Dh",  function() require("dap.ui.widgets").hover() end,     desc = "Debug: hover variable" },
            { "<leader>Du",  function() require("dapui").toggle() end,             desc = "Debug: toggle UI" },
            { "<leader>De",  function() require("dapui").eval() end,               desc = "Debug: eval expression", mode = { "n", "v" } },
            { "<leader>DI",  "<cmd>DapInit<cr>",                                 desc = "Debug: bootstrap .vscode/launch.json" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            require("mason-nvim-dap").setup({
                ensure_installed = { "delve", "python" },
                automatic_installation = true,
                handlers = {},
            })

            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = "scopes",      size = 0.30 },
                            { id = "breakpoints", size = 0.20 },
                            { id = "stacks",      size = 0.25 },
                            { id = "watches",     size = 0.25 },
                        },
                        size = 40,
                        position = "left",
                    },
                    {
                        elements = {
                            { id = "repl",    size = 0.5 },
                            { id = "console", size = 0.5 },
                        },
                        size = 0.30,
                        position = "bottom",
                    },
                },
                floating = { border = "rounded" },
            })

            require("nvim-dap-virtual-text").setup({
                commented = true,
                virt_text_pos = "eol",
            })

            dap.listeners.before.attach.dapui_config       = function() dapui.open() end
            dap.listeners.before.launch.dapui_config       = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui    = function() dapui.close() end
            dap.listeners.before.event_exited.dapui        = function() dapui.close() end

            vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError", linehl = "",       numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn",  linehl = "",       numhl = "" })
            vim.fn.sign_define("DapBreakpointRejected",  { text = "○", texthl = "DiagnosticError", linehl = "",       numhl = "" })
            vim.fn.sign_define("DapLogPoint",            { text = "◆", texthl = "DiagnosticInfo",  linehl = "",       numhl = "" })
            vim.fn.sign_define("DapStopped",             { text = "→", texthl = "DiagnosticOk",    linehl = "Visual", numhl = "" })

            -- nvim-dap auto-loads .vscode/launch.json on demand (see :help dap-providers),
            -- so explicit load_launchjs() calls are no longer needed.

            -- :DapInit — scaffold a generic .vscode/launch.json into the cwd.
            -- Useful for projects that don't have a debug config yet. Existing
            -- files are never overwritten; pass ! to force.
            local launch_json_template = [[{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Go: Debug current file",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "${file}",
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Go: Debug package",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "${workspaceFolder}",
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}",
            "buildFlags": ""
        },
        {
            "name": "Go: Debug nearest test",
            "type": "go",
            "request": "launch",
            "mode": "test",
            "program": "${fileDirname}",
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Python: Debug current file",
            "type": "debugpy",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Python: Debug pytest (current file)",
            "type": "debugpy",
            "request": "launch",
            "module": "pytest",
            "args": ["${file}", "-q"],
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        }
    ]
}
]]

            vim.api.nvim_create_user_command("DapInit", function(opts)
                local cwd = vim.fn.getcwd()
                local dir = cwd .. "/.vscode"
                local file = dir .. "/launch.json"

                if vim.fn.filereadable(file) == 1 and not opts.bang then
                    vim.notify(
                        "launch.json already exists at " .. file .. " — use :DapInit! to overwrite",
                        vim.log.levels.WARN
                    )
                    return
                end

                vim.fn.mkdir(dir, "p")
                local fd, err = io.open(file, "w")
                if not fd then
                    vim.notify("Failed to write launch.json: " .. tostring(err), vim.log.levels.ERROR)
                    return
                end
                fd:write(launch_json_template)
                fd:close()

                vim.notify("Wrote default debug configs to " .. file, vim.log.levels.INFO)
            end, {
                bang = true,
                desc = "Scaffold a generic .vscode/launch.json with Go + Python debug configs",
            })
        end,
    },

    -- ─── Go (delve) ───────────────────────────────────────────────────────────
    -- Auto-discovers tests, packages, and launch.json configurations. Per-project
    -- build flags (e.g. "-tags integration") should live in .vscode/launch.json.
    {
        "leoluz/nvim-dap-go",
        ft = "go",
        dependencies = { "mfussenegger/nvim-dap" },
        opts = {
            delve = {
                build_flags = "",
                detached = vim.fn.has("win32") == 0,
            },
        },
    },

    -- ─── Python (debugpy) ─────────────────────────────────────────────────────
    -- Uses the debugpy installed inside Mason's isolated venv so it never
    -- conflicts with the user's project venv.
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = { "mfussenegger/nvim-dap" },
        keys = {
            { "<leader>pyD", function() require("dap-python").test_method() end, desc = "Python: debug nearest test" },
        },
        config = function()
            local is_win = vim.fn.has("win32") == 1
            local rel = is_win and "/mason/packages/debugpy/venv/Scripts/python.exe"
                                or "/mason/packages/debugpy/venv/bin/python"
            local mason_python = vim.fn.stdpath("data") .. rel
            if vim.fn.executable(mason_python) == 1 then
                require("dap-python").setup(mason_python)
            else
                require("dap-python").setup(is_win and "python" or "python3")
            end
        end,
    },
}

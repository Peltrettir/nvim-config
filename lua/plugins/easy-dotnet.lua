local function add_dotnet_mappings()
    local dotnet = require 'easy-dotnet'

    vim.api.nvim_create_user_command('Secrets', function()
        dotnet.secrets()
    end, {})

    vim.keymap.set('n', '<A-t>', function()
        vim.cmd 'Dotnet testrunner'
    end, { nowait = true, desc = 'Dotnet [T]estrunner show/hide' })

    vim.keymap.set('n', '<A-p>', function()
        vim.cmd 'Dotnet project view'
    end, { nowait = true, desc = 'Dotnet [P]roject view' })

    vim.keymap.set('n', '<C-p>', function()
        vim.cmd 'Dotnet debug profile default'
    end, { nowait = true, desc = 'Dotnet debug [P]rofile defaul' })

    vim.keymap.set('n', '<C-b>', function()
        dotnet.build_default_quickfix()
    end, { nowait = true, desc = 'Doenet [B]uild quickfix' })
end

return {
    {
        'GustavEikaas/easy-dotnet.nvim',
        enabled = true,
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
        config = function()
            local dotnet = require 'easy-dotnet'
            dotnet.setup {
                test_runner = {
                    enable_buffer_test_execution = true,
                    viewmode = 'float',
                    noBuild = false,
                },
                projx_lsp = {
                    enabled = true,
                },
                notifications = {
                    handler = false,
                },
                debugger = {
                    -- vsdbg handshake-terminating shim (setting bin_path forces engine 'custom')
                    -- bin_path = 'C:\\PERSONALE\\vsdbg-shim\\shim.cmd',
                    -- apply_value_converters = false,
                    -- console = 'integratedTerminal',
                    -- auto_register_dap = true,
                },
                auto_bootstrap_namespace = {
                    type = 'file_scoped',
                    enabled = true,
                },
                server = {
                    use_visual_studio = false,
                    ---@type nil | "Off" | "Critical" | "Error" | "Warning" | "Information" | "Verbose" | "All"
                    log_level = 'Information',
                },
                terminal = function(path, action, args, ctx)
                    local commands = {
                        run = function()
                            return string.format('%s %s', ctx.cmd, args)
                        end,
                        test = function()
                            return string.format('%s %s', ctx.cmd, args)
                        end,
                        restore = function()
                            return string.format('%s %s', ctx.cmd, args)
                        end,
                        build = function()
                            return string.format('%s %s', ctx.cmd, args)
                        end,
                        watch = function()
                            return string.format('dotnet watch --project %s %s', path, args)
                        end,
                    }

                    local command = commands[action]() .. '\r'
                    require('toggleterm').exec(command, nil, nil, nil, 'float')
                end,
            }
            add_dotnet_mappings()
        end,
    },
    -- lazy.nvim configuration example for vsdbg-ui
    {
        'kmiterror/dotnet-debug.nvim',
        enabled = false,
        dependencies = { 'mfussenegger/nvim-dap' },
        opts = {
            -- Path to the signing module.
            -- This is typically found within the Visual Studio Code.app bundle on macOS.
            signer_path = 'C:\\Users\\utente\\AppData\\Local\\Programs\\Microsoft VS Code\\fcf604774b\\resources\\app\\node_modules.asar.unpacked\\vsda\\build\\Release\\vsda.node',
            -- This path is often found within the ms-dotnettools.csharp extension for VS Code.
            -- The `~` will be expanded to your home directory.
            -- TEMP: was vsdbg-ui.exe directly; routed through tee wrapper to capture the working transcript.
            debugger_path = 'C:\\Users\\utente\\.vscode\\extensions\\ms-dotnettools.csharp-2.140.9-win32-x64\\.debugger\\x86_64\\vsdbg-ui.exe',
        },
        config = function(_, opts)
            require('dotnet-debug').setup(opts)
        end
    }
}

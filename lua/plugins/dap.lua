local Cache = { dapui_mappings = {} }
local Functions = {
    -- register_lua_dap = function(dap)
    --     dap.configurations.lua = {
    --         -- https://github.com/jbyuki/one-small-step-for-vimkind
    --         {
    --             type = 'nlua',
    --             request = 'attach',
    --             name = 'Attach to running Neovim instance',
    --         },
    --     }
    --     dap.adapters.nlua = function(callback, config)
    --         callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
    --     end
    --
    --     vim.api.nvim_create_user_command('LD', function()
    --         require('osv').launch { port = 8086 }
    --     end, {})
    --
    --     vim.api.nvim_create_user_command('LuaDebug', function()
    --         require('osv').launch { port = 8086 }
    --     end, {})
    -- end,
    setup_dap_bindings = function(dap, dapui)
        local set_debug_mapping = function(mode, lhs, rhs, opts)
            vim.keymap.set(mode, lhs, rhs, opts)
            table.insert(Cache.dapui_mappings, { mode = mode, lhs = lhs })
        end
        local clear_debug_mappings = function()
            for _, m in ipairs(Cache.dapui_mappings) do
                pcall(vim.keymap.del, m.mode, m.lhs)
            end
            Cache.dapui_mappings = {}
        end
        vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debugger continue' })
        vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = '[b]reakpoint toggle' })

        -- dap listeners
        dap.listeners.after.event_stopped['dap_ui'] = function()
            dapui.open()
            set_debug_mapping('n', '<leader>dc', dap.run_to_cursor, { desc = '[d]ebugger run to [c]ursor' })
            set_debug_mapping('n', '<leader>dr', dap.repl.toggle, { desc = '[d]ebugger toggle [r]epl' })
            set_debug_mapping('n', '<leader>de', function()
                dapui.eval()
                dapui.eval()
            end, { desc = '[D]ebugger [E]val under cursor' })
            set_debug_mapping('n', '<leader>dq', dap.close, { desc = '[d]ebugger [q]uit' })
            set_debug_mapping('n', '<F10>', dap.step_over, { desc = 'Debugger step over' })
            set_debug_mapping('n', '<F11>', dap.step_into, { desc = 'Debugger step into' })
            set_debug_mapping('n', '<F12>', dap.step_out, { desc = 'Debugger step out' })
            set_debug_mapping('n', '<F2>', require('dap.ui.widgets').hover, { desc = 'dap ui widgets' })
        end

        dap.listeners.on_session['dap_ui'] = function(_, new)
            clear_debug_mappings()
            if new == nil then
                dapui.close()
            end
        end
    end,
}

return {
    'mfussenegger/nvim-dap',
    enabled = true,
    config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'

        -- dap.configurations.cs = {
        --     {
        --         type = 'coreclr',
        --         name = 'Launch',
        --         request = 'launch',
        --         program = function()
        --             return vim.fn.input('Path to dll: ', vim.fn.getcwd(), 'file')
        --         end,
        --         cwd = function()
        --             return vim.fn.getcwd()
        --         end,
        --     },
        -- }

        dap.set_log_level 'TRACE'

        -- Functions.register_lua_dap(dap)
        Functions.setup_dap_bindings(dap, dapui)

        vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = 'DapBreakpoint', numhl = '' })
        vim.fn.sign_define('DapStopped', { text = '󰳟', texthl = '', linehl = 'DapStopped', numhl = '' })
    end,
    dependencies = {
        -- { 'jbyuki/one-small-step-for-vimkind' },
        {
            'nvim-neotest/nvim-nio',
        },
        {
            'rcarriga/nvim-dap-ui',
            config = function()
                require('dapui').setup {
                    icons = { expanded = '', collapsed = '', current_frame = '' },
                    mappings = {
                        expand = { '<CR>' },
                        open = 'o',
                        remove = 'd',
                        edit = 'e',
                        repl = 'r',
                        toggle = 't',
                    },
                    element_mappings = {},
                    expand_lines = true,
                    force_buffers = true,
                    layouts = {
                        {
                            elements = {
                                { id = 'scopes', size = 1 },
                                -- {
                                --   id = "repl",
                                --   size = 0.66,
                                -- },
                            },

                            size = 10,
                            position = 'bottom',
                        },
                        {
                            elements = {
                                'breakpoints',
                                -- "console",
                                'stacks',
                                'watches',
                            },
                            size = 45,
                            position = 'right',
                        },
                    },
                    floating = {
                        max_height = nil,
                        max_width = nil,
                        border = 'single',
                        mappings = {
                            ['close'] = { 'q', '<Esc>' },
                        },
                    },
                    controls = {
                        enabled = vim.fn.exists '+winbar' == 1,
                        element = 'repl',
                        icons = {
                            pause = '',
                            play = '',
                            step_into = '',
                            step_over = '',
                            step_out = '',
                            step_back = '',
                            run_last = '',
                            terminate = '',
                            disconnect = '',
                        },
                    },
                    render = {
                        max_type_length = nil, -- Can be integer or nil.
                        max_value_lines = 100, -- Can be integer or nil.
                        indent = 1,
                    },
                }
            end,
        },
    },
}

return {
    { -- Fuzzy Finder (files, lsp, etc)
        'nvim-telescope/telescope.nvim',
        cmd = 'Telescope',
        init = function()
            -- telescope-ui-select takes over vim.ui.select when telescope loads, so load it on first use
            local select = vim.ui.select
            vim.ui.select = function(...)
                vim.ui.select = select
                require 'telescope'
                return vim.ui.select(...)
            end
        end,
        keys = {
            { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
            { '<leader>sk', function() require('telescope.builtin').keymaps() end, desc = '[S]earch [K]eymaps' },
            { '<leader>sf', function() require('telescope.builtin').find_files() end, desc = '[S]earch [F]iles' },
            { '<leader>ss', function() require('telescope.builtin').builtin() end, desc = '[S]earch [S]elect Telescope' },
            { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
            { '<leader>sg', function() require('telescope.builtin').live_grep() end, mode = { 'n', 'i' }, desc = '[S]earch by [G]rep' },
            { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
            { '<leader>sr', function() require('telescope.builtin').resume() end, desc = '[S]earch [R]esume' },
            { '<leader>st', function() require('telescope.builtin').treesitter() end, desc = '[S]earch [T]reesitter' },
            { '<leader>sl', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, desc = '[S]earch [L]sp workspace symbols' },
            { '<leader>s.', function() require('telescope.builtin').oldfiles() end, desc = '[S]earch Recent Files ("." for repeat)' },
            { '<leader><leader>', function() require('telescope.builtin').buffers() end, desc = '[ ] Find existing buffers' },
            {
                '<leader>/',
                function()
                    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                        winblend = 10,
                        previewer = false,
                    })
                end,
                desc = '[/] Fuzzily search in current buffer',
            },
            {
                '<leader>s/',
                function()
                    require('telescope.builtin').live_grep {
                        grep_open_files = true,
                        prompt_title = 'Live Grep in Open Files',
                    }
                end,
                desc = '[S]earch [/] in Open Files',
            },
            {
                '<leader>sn',
                function()
                    require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
                end,
                desc = '[S]earch [N]eovim files',
            },
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                'nvim-telescope/telescope-fzf-native.nvim',

                -- `build` is used to run some command when the plugin is installed/updated.
                -- This is only run then, not every time Neovim starts up.
                build = 'make',

                -- `cond` is a condition used to determine whether this plugin should be
                -- installed and loaded.
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
            { 'nvim-telescope/telescope-ui-select.nvim' },

            -- Useful for getting pretty icons, but requires a Nerd Font.
            { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
        },
        config = function()
            -- [[ Configure Telescope ]]
            local actions = require 'telescope.actions'
            require('telescope').setup {
                defaults = {
                    wrap_results = true,
                    mappings = {
                        i = {
                            ['<esc>'] = actions.close,
                            ['<c-h>'] = 'which_key',
                        },
                    },
                    vimgrep_arguments = {
                        'rg',
                        '--color=never',
                        '--no-heading',
                        '--with-filename',
                        '--line-number',
                        '--column',
                        '--smart-case',
                        '--trim',
                        '--multiline',
                    },
                },
                pickers = {
                    buffers = {
                        mappings = {
                            i = {
                                ['<c-d>'] = actions.delete_buffer + actions.move_to_top,
                            },
                        },
                    },
                },
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                },
            }

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')
        end,
    },
}

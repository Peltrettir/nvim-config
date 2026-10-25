return {
    'saghen/blink.cmp',
    version = '1.*',
    event = 'InsertEnter', -- also loaded with nvim-lspconfig, which lists it as a dependency
    dependencies = {
        -- Snippet Engine
        {
            'L3MON4D3/LuaSnip',
            version = '2.*',
            build = (function()
                -- Build Step is needed for regex support in snippets.
                -- This step is not supported in many windows environments.
                -- Remove the below condition to re-enable on windows.
                if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                    return
                end
                return 'make install_jsregexp'
            end)(),
            dependencies = {
                -- `friendly-snippets` contains a variety of premade snippets.
                --    See the README about individual language/framework/plugin snippets:
                --    https://github.com/rafamadriz/friendly-snippets
                -- {
                --   'rafamadriz/friendly-snippets',
                --   config = function()
                --     require('luasnip.loaders.from_vscode').lazy_load()
                --   end,
                -- },
            },
            opts = {},
        },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
        keymap = {
            preset = 'default',
            ['<C-Space>'] = false,
            ['<M-.>'] = { 'show' },

            -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
            --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },

        appearance = {
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono',
        },

        completion = {
            -- By default, you may press `<c-space>` to show the documentation.
            -- Optionally, set `auto_show = true` to show the documentation after a delay.
            documentation = { auto_show = false, auto_show_delay_ms = 500 },
        },

        sources = {
            -- blink requires a provider's module as soon as it is listed, and requiring
            -- easy-dotnet's module would load the whole plugin outside a workspace.
            -- blink calls this on every completion request, so the source shows up as soon as easy-dotnet loads.
            default = function()
                if package.loaded['easy-dotnet'] then
                    return { 'lsp', 'easy-dotnet', 'path', 'snippets' }
                end
                return { 'lsp', 'path', 'snippets' }
            end,
            providers = {
                ['easy-dotnet'] = {
                    name = 'easy-dotnet',
                    enabled = true,
                    module = 'easy-dotnet.completion.blink',
                    score_offset = 10000,
                    async = true,
                },
                orgmode = {
                    name = 'Orgmode',
                    module = 'orgmode.org.autocompletion.blink',
                    fallbacks = { 'buffer' },
                },
                lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
            },
            per_filetype = {
                org = { 'orgmode' },
                -- same reason as easy-dotnet: listing lazydev everywhere would load it in every buffer
                lua = { inherit_defaults = true, 'lazydev' },
            },
        },

        snippets = { preset = 'luasnip' },

        fuzzy = { implementation = 'prefer_rust_with_warning' },

        -- Shows a signature help window while you type arguments for a function
        signature = { enabled = true },
    },
}

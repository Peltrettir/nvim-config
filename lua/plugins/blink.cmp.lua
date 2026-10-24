return {
    'saghen/blink.cmp',
    version = '*',
    config = function()
        require('blink.cmp').setup {
            fuzzy = { implementation = 'prefer_rust_with_warning' },
            sources = {
                default = { 'lsp', 'easy-dotnet', 'path' },
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
                },
                per_filetype = {
                    org = { 'orgmode' },
                },
            },
        }
    end,
}

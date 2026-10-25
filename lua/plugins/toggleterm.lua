function setup_powershell_options()
    local powershell_options = {
        shell = 'pwsh',
        shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
        shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait',
        shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode',
        shellquote = '',
        shellxquote = '',
    }

    for option, value in pairs(powershell_options) do
        vim.opt[option] = value
    end
end
return {
    'akinsho/toggleterm.nvim',
    -- shell options apply to :! too, so set them at startup rather than when toggleterm loads
    init = function()
        if vim.fn.has 'win32' == 1 then
            setup_powershell_options()
        end
    end,
    cmd = { 'ToggleTerm', 'TermExec' },
    keys = {
        { '<A-i>', mode = { 'n', 't' } },
    },
    config = function()
        -- floating terminal size as a fraction of the editor; <A-f> cycles through these
        local float_sizes = { 0.8, 1 }
        local float_size = 1

        require('toggleterm').setup {
            open_mapping = '<C-\\>',
            start_in_insert = true,
            direction = 'float',
            float_opts = {
                -- the border takes one cell on each side, so 1 covers the whole editor
                width = function()
                    return math.floor((vim.o.columns - 2) * float_sizes[float_size])
                end,
                height = function()
                    return math.floor((vim.o.lines - vim.o.cmdheight - 2) * float_sizes[float_size])
                end,
            },
        }

        vim.keymap.set({ 'n', 't' }, '<A-f>', function()
            float_size = float_size % #float_sizes + 1
            local term = require('toggleterm.terminal').get(vim.b.toggle_number)
            if term and term:is_float() then
                require('toggleterm.ui').update_float(term)
            end
        end, { desc = 'Cycle floating terminal size' })

        vim.keymap.set({ 'n', 't' }, '<A-i>', function()
            require('toggleterm').toggle(1, nil, nil, 'float')
        end, { noremap = true, silent = true })
        vim.keymap.set({ 'n', 't' }, '<A-h>', function()
            require('toggleterm').toggle(2, nil, nil, 'horizontal')
        end, { noremap = true, silent = true })

        function _G.set_terminal_keymaps()
            local opts = { buffer = 0 }
            vim.keymap.set('t', 'jj', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
        end

        -- if you only want these mappings for toggle term use term://*toggleterm#* instead
        vim.cmd 'autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()'
    end,
}

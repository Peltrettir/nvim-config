-- [[ Basic Keymaps ]]

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Insert to Normal mode' })

-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- NOTE: Window operations
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-down>', function()
    vim.cmd 'resize -1'
end, { desc = 'Resize window reduce height' })
vim.keymap.set('n', '<C-up>', function()
    vim.cmd 'resize +1'
end, { desc = 'Resize window increase height' })
vim.keymap.set('n', '<C-left>', function()
    vim.cmd 'vertical resize -1'
end, { desc = 'Resize window reduce width' })
vim.keymap.set('n', '<C-right>', function()
    vim.cmd 'vertical resize +1'
end, { desc = 'Resize window increase width' })

-- NOTE: Windows default association don't require GUI applications
-- manually mapped text files to nvim
vim.keymap.set('n', 'gx', function()
    local target = vim.fn.expand '<cfile>'

    local nvim_extensions = {
        md = true,
        txt = true,
        log = true,
        cs = true,
        py = true,
        json = true,
    }

    -- helper: extract extension
    local function get_ext(path)
        return path:match '^.+%.([^./\\#]+)'
    end

    -- strip markdown anchors
    local clean_target = target:gsub('#.*$', '')
    local ext = get_ext(clean_target)

    -- open inside nvim if allowed
    if ext == nil or nvim_extensions[ext:lower()] then
        vim.cmd('edit ' .. vim.fn.fnameescape(target))
        return
    end

    -- detect OS
    local sysname = vim.loop.os_uname().sysname

    if sysname == 'Windows_NT' then
        -- Windows
        vim.fn.jobstart({ 'cmd', '/c', 'start', target }, { detach = true })
    elseif sysname == 'Linux' then
        -- WSL / Linux
        -- prefer xdg-open (works in WSL if properly configured)
        vim.fn.jobstart({ 'xdg-open', target }, { detach = true })
    elseif sysname == 'Darwin' then
        -- macOS (optional, for completeness)
        vim.fn.jobstart({ 'open', target }, { detach = true })
    end
end, { silent = true, desc = 'open link with os default application' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
vim.keymap.set('n', '<C-S-h>', '<C-w>H', { desc = 'Move window to the left' })
vim.keymap.set('n', '<C-S-l>', '<C-w>L', { desc = 'Move window to the right' })
vim.keymap.set('n', '<C-S-j>', '<C-w>J', { desc = 'Move window to the lower' })
vim.keymap.set('n', '<C-S-k>', '<C-w>K', { desc = 'Move window to the upper' })

-- NOTE: Insert mode keymaps
vim.keymap.set('i', '<C-H>', '<esc>ldbi', { silent = true, desc = 'delete from cursor to beginning of word' })
vim.keymap.set('i', '<C-Del>', '<esc>dwi', { silent = true, desc = 'delete from cursor to ending of word' })

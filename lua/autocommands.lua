-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
    desc = 'User treesitter folding whenever available',
    group = vim.api.nvim_create_augroup('LspFolding', { clear = true }),
    callback = function(args)
        local ok = pcall(vim.treesitter.get_parser, args.buf)
        if ok then
            vim.api.nvim_buf_call(args.buf, function()
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            end)
        end
    end,
})

-- vim.api.nvim_create_autocmd('BufWritePost', {
--     desc = 'When saving orgfiles mark reload agenda if not previously existing',
--     pattern = '*.org',
--     callback = function(args)
--         if vim.b.org_file_existed then
--             return
--         end
--
--         vim.b.org_file_existed = true
--         local orgmode = require 'orgmode'
--         orgmode.files:reload()
--         -- orgmode.superagenda:update_agenda()
--     end,
-- })
--
-- vim.api.nvim_create_autocmd('BufReadPost', {
--     desc = 'When opening orgfiles mark them as existing',
--     pattern = '*.org',
--     callback = function()
--         vim.b.org_file_existed = true
--     end,
-- })

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Follow markdown links to file and #anchor',
    pattern = 'markdown',
    group = vim.api.nvim_create_augroup('markdown-follow-link', { clear = true }),
    callback = function(args)
        vim.keymap.set('n', 'gf', function()
            local line, col = vim.api.nvim_get_current_line(), vim.fn.col '.'
            -- find the (target) whose parens span the cursor
            local target
            for s, t, e in line:gmatch '()%((%S-)()%)' do
                if col >= s and col <= e then
                    target = t
                    break
                end
            end
            if not target then
                return vim.cmd 'normal! gf'
            end

            local file, anchor = target:match '^([^#]*)#?(.*)$'
            if file ~= '' then
                local path = vim.fs.normalize(vim.fn.expand('%:h') .. '/' .. file)
                if vim.fn.filereadable(path) == 0 then
                    return vim.notify('No such file: ' .. path, vim.log.levels.WARN)
                end
                vim.cmd.edit(vim.fn.fnameescape(path))
            end
            if anchor == '' then
                return
            end

            -- GitHub anchors: lowercase, punctuation dropped, spaces -> '-'
            for nr, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
                local heading = l:match '^#+%s+(.*)'
                if heading then
                    local slug = heading
                        :lower()
                        :gsub('%[([^%]]*)%]%b()', '%1') -- links -> their text
                        :gsub('[`*_]', '')
                        :gsub('[^%w%s-]', '')
                        :gsub('%s', '-')
                    if slug == anchor then
                        vim.api.nvim_win_set_cursor(0, { nr, 0 })
                        return vim.cmd 'normal! zz'
                    end
                end
            end
            vim.notify('No heading for #' .. anchor, vim.log.levels.WARN)
        end, { buffer = args.buf, desc = 'Follow markdown link' })
    end,
})

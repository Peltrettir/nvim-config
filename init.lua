function add_runtimepath_folders()
    local sep = package.config:sub(1, 1)
    local base_path = string.sub(debug.getinfo(1).source, 2, string.len '/init.lua' * -1 - 1)

    package.path = base_path
        .. sep
        .. '?.lua;'
        .. base_path
        .. sep
        .. '?'
        .. sep
        .. 'init.lua;'
        .. base_path
        .. sep
        .. 'lua'
        .. sep
        .. '?.lua;'
        .. base_path
        .. sep
        .. 'lua'
        .. '?'
        .. sep
        .. 'init.lua;'
        .. package.path

    vim.opt.rtp:prepend(base_path)
end

function install_lazy()
    local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
        local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
        if vim.v.shell_error ~= 0 then
            error('Error cloning lazy.nvim:\n' .. out)
        end
    end

    ---@type vim.Option
    vim.opt.rtp:prepend(lazypath)
end

add_runtimepath_folders()
install_lazy()

require 'set'
require 'autocommands'
require 'keymap'
require('lazy').setup({
    { import = 'plugins' },
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤',
        },
    },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

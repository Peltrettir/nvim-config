---@param folders string[]|nil
---@return string|nil, Path|nil, message|nil
function get_folder(folders)
    ---@type utils
    local utils = require 'utils'

    local separator, error = utils.separator()
    if error ~= nil then
        return nil, nil, error
    end

    local user_data_folder, error = utils.user_data_folder()
    if error ~= nil then
        return nil, nil, error
    end

    local requested_folder = user_data_folder .. 'orgfiles' .. separator
    if folders ~= nil and #folders > 0 then
        for _, folder in ipairs(folders) do
            if not utils.is_null_or_empty(folder) then
                requested_folder = requested_folder .. folder .. separator
            end
        end
    end

    error = utils.ensure_folder(requested_folder)
    if error ~= nil then
        return nil, nil, error
    end

    return separator, requested_folder, nil
end

local separator, orgmode_folder, error = get_folder()
if error ~= nil then
    vim.notify(error, vim.log.levels.ERROR)
    return
end

local agenda_files = {
    orgmode_folder .. '*.org',
    orgmode_folder .. '**' .. separator .. '*.org',
}

return {
    {
        'nvim-orgmode/orgmode',
        event = 'VeryLazy',
        dependencies = {'nvim-treesitter'},
        config = function()
            require('orgmode.utils.treesitter.install').compilers = { 'gcc' }
            require('orgmode').setup {
                org_agenda_files = agenda_files,
                org_default_notes_file = orgmode_folder .. 'refile.org',
                mappings = {
                    global = {
                        org_agenda = false,
                    },
                },
            }
            require('nvim-treesitter.parsers').org = {
                install_info = {
                    url = vim.fn.stdpath 'data' .. separator .. 'orgmode' .. separator .. 'parser' .. separator, -- local path or git repo
                    files = { 'org.so' }, -- or parser.cc
                    branch = 'main',
                },
                filetype = 'org',
            }
            -- Experimental LSP support
            vim.lsp.enable 'org'
        end,
    },
    {
        'hamidi-dev/org-super-agenda.nvim',
        cmd = 'OrgSuperAgenda',
        keys = {
            { '<leader>oa', '<cmd>OrgSuperAgenda<cr>', desc = '[o]rgmode [a]genda' },
            { '<leader>oA', '<cmd>OrgSuperAgenda!<cr>', desc = '[o]rgmone [A]agenda fullscreen' },
        },
        enabled = true, --got the agenda to find todos, but actions don't work. They seem to pick up the wrong line numbers, I don't know why
        dependencies = {
            'nvim-orgmode/orgmode', -- required
            'lukas-reineke/headlines.nvim',
        },
        config = function()
            local files = {}
            for _, val in ipairs(agenda_files) do
                vim.list_extend(files, vim.fn.glob(val, false, true))
            end
            require('org-super-agenda').setup {
                -- Where to look for .org files
                org_files = files,

                -- TODO states + their quick filter keymaps and highlighting
                -- Optional: add `shortcut` field to override the default key (first letter)
                todo_states = {
                    {
                        name = 'TODO',
                        keymap = 'ot',
                        color = '#FF5555',
                        strike_through = false,
                        fields = {
                            'filename',
                            'todo',
                            'headline',
                            'priority',
                            'date',
                            'tags',
                        },
                    },
                    {
                        name = 'PROGRESS',
                        keymap = 'op',
                        color = '#FFAA00',
                        strike_through = false,
                        fields = {
                            'filename',
                            'todo',
                            'headline',
                            'priority',
                            'date',
                            'tags',
                        },
                    },
                    {
                        name = 'WAITING',
                        keymap = 'ow',
                        color = '#BD93F9',
                        strike_through = false,
                        fields = {
                            'filename',
                            'todo',
                            'headline',
                            'priority',
                            'date',
                            'tags',
                        },
                    },
                    {
                        name = 'DONE',
                        keymap = 'od',
                        color = '#50FA7B',
                        strike_through = true,
                        fields = { 'filename', 'todo', 'headline', 'priority', 'date', 'tags' },
                    },
                },

                -- Group definitions (order matters; first match wins unless allow_duplicates=true)
                groups = {
                    {
                        name = '📅 Today',
                        matcher = function(i)
                            return i.scheduled and i.scheduled:is_today()
                        end,
                        sort = { by = 'scheduled_time', order = 'asc' },
                    },
                    {
                        name = '🗓️ Tomorrow',
                        matcher = function(i)
                            return i.scheduled and i.scheduled:days_from_today() == 1
                        end,
                        sort = { by = 'scheduled_time', order = 'asc' },
                    },
                    {
                        name = '☠️ Deadlines',
                        matcher = function(i)
                            return i.deadline and i.todo_state ~= 'DONE' and not i:has_tag 'personal'
                        end,
                        sort = { by = 'deadline', order = 'asc' },
                    },
                    {
                        name = '⭐ Important',
                        matcher = function(i)
                            return i.priority == 'A' and (i.deadline or i.scheduled)
                        end,
                        sort = { by = 'date_nearest', order = 'asc' },
                    },
                    {
                        name = '⏳ Overdue',
                        matcher = function(i)
                            return i.todo_state ~= 'DONE' and ((i.deadline and i.deadline:is_past()) or (i.scheduled and i.scheduled:is_past()))
                        end,
                        sort = { by = 'date_nearest', order = 'asc' },
                    },
                    {
                        name = '🏠 Personal',
                        matcher = function(i)
                            return i:has_tag 'personal'
                        end,
                    },
                    {
                        name = '💼 Work',
                        matcher = function(i)
                            return i:has_tag 'work'
                        end,
                    },
                    {
                        name = '📆 Upcoming',
                        matcher = function(i)
                            local days = require('org-super-agenda.config').get().upcoming_days or 10
                            local d1 = i.deadline and i.deadline:days_from_today()
                            local d2 = i.scheduled and i.scheduled:days_from_today()
                            return (d1 and d1 >= 0 and d1 <= days) or (d2 and d2 >= 0 and d2 <= days)
                        end,
                        sort = { by = 'date_nearest', order = 'asc' },
                    },
                },

                hide_empty_groups = false, -- drop blank sections
                group_format = '* %s', -- group header format
                other_group_name = 'Other',
                show_other_group = true, -- show catch-all section
            }

        end,
    },
    {
        'akinsho/org-bullets.nvim',
        ft = 'org',
        config = function()
            require('org-bullets').setup {
                symbols = {
                    -- list symbol
                    list = '•',
                    -- headlines can be a list
                    headlines = { '◉', '○', '✸', '✿' },
                    checkboxes = {
                        half = { '', '@org.checkbox.halfchecked' },
                        done = { '✓', '@org.keyword.done' },
                        todo = { '˟', '@org.keyword.todo' },
                    },
                },
            }
        end,
    },
    {
        'nvim-orgmode/telescope-orgmode.nvim',
        keys = {
            {
                '<leader>so',
                function()
                    require('telescope').extensions.orgmode.search_headings()
                end,
                desc = '[S]earch [O]rgfiles',
            },
        },
        dependencies = {
            'nvim-orgmode/orgmode',
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            require('telescope').load_extension 'orgmode'
        end,
    },
    {
        'chipsenkbeil/org-roam.nvim',
        ft = 'org',
        keys = { { '<leader>n', desc = 'org-roam' } }, -- org-roam's default binding prefix
        tag = '0.2.0',
        dependencies = {
            {
                'nvim-orgmode/orgmode',
                tag = '0.7.0',
            },
        },
        config = function()
            local separator, orgroam_folder, error = get_folder { 'orgroam' }
            if error ~= nil then
                vim.notify(error, vim.log.levels.ERROR)
                return
            end

            require('org-roam').setup {
                directory = orgroam_folder,
                -- optional
                org_files = {
                    orgroam_folder .. '..' .. separator .. '*.org',
                    orgroam_folder .. '..' .. separator .. '**' .. separator .. '*.org',
                },
                database = {
                    path = orgroam_folder .. 'persistence.db',
                },
            }
        end,
    },
}

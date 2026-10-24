---@alias Path string
---@alias message string

local cache = {}
local PERSONALE_ENV_KEY = 'PERSONALE'

---@class utils
---@field user_data_folder fun(): Path|nil, nil|message
---@field disk_root fun(): Path|nil, nil|message
---@field separator fun(): string|nil, nil|message
---@field is_null_or_empty fun(s: string|nil): boolean
---@field ensure_folder fun(path: Path): nil|message
local M = {}

---@return Path|nil, nil|message
function M.user_data_folder()
    if cache.user_data_folder ~= nil then
        return cache.user_data_folder, nil
    end

    local folder_path = vim.fn.getenv(PERSONALE_ENV_KEY)
    if M.is_null_or_empty(folder_path) then
        if vim.loop.os_uname().sysname == "Windows_NT" then
            folder_path = 'C:/Personale'
        else
            folder_path = vim.fn.expand('~/personale')
        end
    end

    local error = M.ensure_folder(folder_path)
    if not M.is_null_or_empty(error) then
        return nil, error
    end

    local separator, error = M.separator()
    if not M.is_null_or_empty(error) then
        return nil, error
    end

    if folder_path:sub(-1) ~= separator then
        folder_path = folder_path .. separator
    end

    cache.user_data_folder = folder_path
    return cache.user_data_folder, nil
end

---@return Path|nil, nil|message
function M.disk_root()
    if cache.disk_root ~= nil then
        return cache.disk_root, nil
    end

    local separator, error = M.separator()
    if not M.is_null_or_empty(error) then
        return nil, error
    end

    local cwd = vim.fn.getcwd()
    if M.is_null_or_empty(cwd) then
        return nil, 'Could not retrieve current working directory'
    end

    local root = cwd:match('^[^' .. separator .. ']*' .. separator)
    if M.is_null_or_empty(root) then
        return nil, 'Could not retrieve disk root'
    end

    cache.disk_root = root
    return cache.disk_root, nil
end

---@return string|nil, nil|message
function M.separator()
    if cache.separator ~= nil then
        return cache.separator
    end

    local success, value = pcall(string.sub, package.config, 1, 1)
    if not success then
        return nil, 'Error retrieving system separator: ' .. value
    end

    cache.separator = value
    return cache.separator
end

---@param s string|nil
---@return boolean
function M.is_null_or_empty(s)
    return s == nil or s == vim.NIL or s:match '^%s*$' ~= nil
end

---@param path Path
---@return nil|message
function M.ensure_folder(path)
    if M.is_null_or_empty(path) then
        return 'Invalid argument, nil or empty path'
    end

    if vim.fn.isdirectory(path) then
        return nil
    end

    for subpath in M.get_subpaths(path) do
        if vim.fn.isdirectory(subpath) then
            return nil
        end
        local result = os.execute 'mkdir ' .. subpath
        if result ~= 0 then
            return 'Error creating directory ' .. subpath
        end
    end

    return nil
end

---@param path Path
---@return string[]|nil, message|nil
function M.get_subpaths(path)
    if M.is_null_or_empty(path) then
        return nil, 'Invalid argument, nil or empty path'
    end

    local sep, error = M.separator()
    if error ~= nil then
        return nil, error
    end

    local subpaths = {}
    for match in path:gmatch('[^' .. sep .. ']+') do
        local prev = ''
        local subpaths_count = #subpaths

        if subpaths_count ~= 0 then
            prev = subpaths[subpaths_count]
        end

        subpaths[subpaths_count + 1] = prev .. sep .. match
    end

    return subpaths, nil
end

return M

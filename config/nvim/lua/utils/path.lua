local M = {}

local function human_friendly_tokens(tokens)
  if not tokens then
    return '0'
  end
  if tokens >= 1000 then
    return string.format('%.1fk', tokens / 1000)
  else
    return tostring(tokens)
  end
end

-- Custom icons configuration
-- Format: { icon, hl_group, text? }
-- The text field is optional and can be:
--   - string: static text to display
--   - function(bufnr): function that returns text based on buffer
local custom_icons = {
  gitrebase = { '', 'DevIconGitCommit', 'Rebase' },
  help = {
    '󰋖',
    'DevIconTxt',
    function(bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      return vim.fn.fnamemodify(bufname, ':t:r') -- filename without extension
    end,
  },
  oil = { '', 'OilDir', 'File Explorer' },
}

---@param path string
---@return string[]
local function split_path(path)
  if path == '' then
    return {}
  end

  -- Normalize path separators and remove trailing slash
  path = path:gsub('\\', '/'):gsub('/$', '')

  local parts = {}
  for part in path:gmatch '[^/]+' do
    table.insert(parts, part)
  end
  return parts
end

---Calculate minimum unique paths for a set of file paths
---@param paths string[] List of full file paths
---@return table<string, string> Map of full path to display path
local function calculate_unique_paths(paths)
  if #paths == 0 then
    return {}
  end

  if #paths == 1 then
    local parts = split_path(paths[1])
    return { [paths[1]] = parts[#parts] or '' }
  end

  local path_parts = {}
  for _, path in ipairs(paths) do
    path_parts[path] = split_path(path)
  end

  local result = {}

  for _, path in ipairs(paths) do
    local parts = path_parts[path]
    local filename = parts[#parts]

    if not filename then
      result[path] = ''
      goto continue
    end

    local depth = 1
    local is_unique = false

    while depth <= #parts and not is_unique do
      local candidate_parts = {}
      for i = math.max(1, #parts - depth + 1), #parts do
        table.insert(candidate_parts, parts[i])
      end
      local candidate = table.concat(candidate_parts, '/')

      is_unique = true
      for _, other_path in ipairs(paths) do
        if other_path ~= path then
          local other_parts = path_parts[other_path]

          local other_candidate_parts = {}
          for i = math.max(1, #other_parts - depth + 1), #other_parts do
            table.insert(other_candidate_parts, other_parts[i])
          end
          local other_candidate = table.concat(other_candidate_parts, '/')

          if candidate == other_candidate then
            is_unique = false
            break
          end
        end
      end

      if is_unique then
        result[path] = candidate
      else
        depth = depth + 1
      end
    end

    if not result[path] then
      result[path] = path
    end

    ::continue::
  end

  return result
end

---Get all visible windows in current tabpage with their buffer paths
---@param tabpage? integer Tabpage handle (default: current tabpage)
---@return table<integer, string> Map of bufnr to full path
local function get_visible_paths(tabpage)
  tabpage = tabpage or 0
  local paths = {}
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)

  for _, win in ipairs(wins) do
    -- Skip floating windows
    local config = vim.api.nvim_win_get_config(win)
    if config.relative == '' then
      local bufnr = vim.api.nvim_win_get_buf(win)
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      -- Only include normal files with paths
      if bufname ~= '' and vim.bo[bufnr].buftype == '' then
        paths[bufnr] = bufname
      end
    end
  end

  return paths
end

local path_cache = {
  tabpage = nil,
  paths = {},
  unique_paths = {},
}

---Get the unique display path for a buffer
---@param bufnr integer
---@param tabpage? integer Tabpage handle (default: current tabpage)
---@return string
function M.get_unique_path(bufnr, tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()

  if path_cache.tabpage ~= tabpage then
    path_cache.tabpage = tabpage

    M.invalidate_cache()
  end

  local visible_paths = get_visible_paths(tabpage)

  local needs_recalc = false
  if vim.tbl_count(visible_paths) ~= vim.tbl_count(path_cache.paths) then
    needs_recalc = true
  else
    for buf, path in pairs(visible_paths) do
      if path_cache.paths[buf] ~= path then
        needs_recalc = true
        break
      end
    end
  end

  if needs_recalc then
    local paths_list = {}
    for _, path in pairs(visible_paths) do
      table.insert(paths_list, path)
    end

    local unique_map = calculate_unique_paths(paths_list)

    path_cache.paths = visible_paths
    path_cache.unique_paths = {}
    for buf, path in pairs(visible_paths) do
      path_cache.unique_paths[buf] = unique_map[path]
    end
  end

  return path_cache.unique_paths[bufnr] or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
end

function M.invalidate_cache()
  path_cache.paths = {}
  path_cache.unique_paths = {}
end

---Get icon, color, and optional text for a buffer, checking custom icons first
---@param bufnr integer Buffer number
---@param devicons? table nvim-web-devicons module (optional)
---@return string|nil icon The icon character
---@return string|nil color The color/highlight group
---@return string|nil text Optional text to display with the icon
function M.get_icon_color(bufnr, devicons)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local filename = vim.fn.fnamemodify(bufname, ':t')
  local filetype = vim.bo[bufnr].filetype

  local icon = nil
  local color = nil
  local text = nil
  if filetype ~= '' and custom_icons[filetype] then
    local color_util = require 'utils.color'
    local icon_config = custom_icons[filetype]
    icon = icon_config[1]
    local icon_color = icon_config[2]
    if icon_color:sub(1, 1) == '#' then
      color = icon_color
    else
      color = color_util.get_hl_color(icon_config[2])
    end
    text = icon_config[3]

    if type(text) == 'function' then
      text = text(bufnr)
    end
  elseif devicons and filename ~= '' then
    icon, color = devicons.get_icon_color(filename)
  end

  return icon, color, text
end

return M

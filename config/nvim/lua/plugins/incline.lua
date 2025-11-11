local SEP = ' '
local DIR_MAX_LEN = 3

local function split_path(path)
  local parts = vim.split(path, '/', { trimempty = true })
  if #parts == 0 then
    return parts
  end
  parts[#parts] = nil
  return parts
end

---@param path string
---@return string[]
local function shorten_dir(path)
  local parts = split_path(path)
  local slice = {} ---@type string[]
  local ellipsis = '...'
  if #parts <= DIR_MAX_LEN then
    return parts
  else
    local prefix_count = math.floor(DIR_MAX_LEN / 2)
    local suffix_count = DIR_MAX_LEN - prefix_count
    for i = 1, prefix_count do
      slice[i] = parts[i]
    end
    slice[prefix_count + 1] = ellipsis
    for i = 1, suffix_count do
      slice[prefix_count + 1 + i] = parts[#parts - suffix_count + i]
    end
  end
  return slice
end

local function render_icons(props)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
  local devicons = require 'nvim-web-devicons'
  local helpers = require 'incline.helpers'
  local ft_icon, ft_color = devicons.get_icon_color(filename)

  return ft_icon and { SEP, ft_icon, SEP, guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or ''
end

local function render_dir(props)
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':p:.')
  local dir = shorten_dir(path)

  if dir and dir[1] == 'oil:' then
    return { '' }
  end

  return dir and { table.concat(dir, '/') .. '/' } or ''
end

local function render_filename(props)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
  if filename == '' then
    filename = '[No Name]'
  end
  local modified = vim.bo[props.buf].modified
  return { filename, gui = modified and 'bold,italic' or 'bold' }
end

local function render_diag(props)
  local diag_icons = { error = '', warn = '', info = '', hint = '' }
  local entries = {}

  for severity, icon in pairs(diag_icons) do
    local count = #vim.diagnostic.get(props.buf, {
      severity = vim.diagnostic.severity[string.upper(severity)],
    })
    if count > 0 then
      table.insert(entries, {
        SEP .. icon .. SEP .. count,
        group = 'DiagnosticSign' .. severity,
      })
    end
  end
  return entries
end

local function render(props)
  local diag = render_diag(props)
  local icons = render_icons(props)
  local dir = render_dir(props)
  local filename = render_filename(props)

  local results = {}

  if #diag > 0 then
    table.insert(results, {
      { diag, SEP },
      guibg = 'none',
    })
  end

  if #icons > 0 then
    table.insert(results, icons)
  end

  if #dir > 0 then
    table.insert(results, { SEP, dir })
  end
  if #filename > 0 then
    table.insert(results, { filename, SEP })
  end

  return results
end

return {
  'b0o/incline.nvim',
  event = { 'BufRead', 'BufNewFile', 'BufEnter' },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = { 'OilEnter', 'OilSelect', 'OilClose' },
      callback = function()
        vim.defer_fn(function()
          require('incline').refresh()
        end, 0)
      end,
    })

    require('incline').setup {
      window = {
        padding = 0,
        margin = { horizontal = 0 },
      },
      ignore = {
        filetypes = { 'oil' },
      },
      render = function(props)
        return {
          render(props),
          guibg = 'none',
        }
      end,
    }
  end,
}

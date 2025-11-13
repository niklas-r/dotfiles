local M = {}

local symbols = {
  readonly = '',
  ellipsis = '…',
}

local sep = {
  spacer = ' ',
}

local function is_readonly(props)
  return vim.bo[props.buf].modifiable == false or vim.bo[props.buf].readonly == true
end

local function render_icons(props)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
  local devicons = require 'nvim-web-devicons'
  local helpers = require 'incline.helpers'
  local ft_icon, ft_color = devicons.get_icon_color(filename)

  local result = {}

  if ft_icon then
    table.insert(result, { sep.spacer, ft_icon, sep.spacer, guibg = ft_color, guifg = helpers.contrast_color(ft_color) })
  end

  if is_readonly(props) then
    table.insert(result, { sep.spacer, symbols.readonly, group = 'NonText' })
  end

  return result
end

local function render_pretty_path(props)
  local is_focused = vim.api.nvim_get_current_win() == props.win
  return vim.api.nvim_win_call(props.win, function()
    local result = M.pretty_path_component:update_status(is_focused)
    local statusline = M.helpers.eval_statusline(result)
    return statusline
  end)
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
        sep.spacer .. icon .. sep.spacer .. count,
        group = 'DiagnosticSign' .. severity,
      })
    end
  end
  return entries
end

local render_extras = function(props)
  return vim.api.nvim_win_call(props.win, function()
    if vim.g.disable_autoformat or vim.b[props.buf].disable_autoformat then
      return { '󰉥', group = 'Error' }
    end

    return {}
  end)
end

local function render(props)
  local diag = render_diag(props)
  local icons = render_icons(props)
  local pretty_path = render_pretty_path(props)
  local extras = render_extras(props)

  local results = {}

  if #diag > 0 then
    table.insert(results, {
      { diag, sep.spacer },
      guibg = 'none',
    })
  end

  if #icons > 0 then
    table.insert(results, icons)
  end

  table.insert(results, { sep.spacer, pretty_path, sep.spacer })

  if #extras > 0 then
    table.insert(results, { extras, sep.spacer })
  end

  return results
end

return {
  'b0o/incline.nvim',
  event = { 'BufRead', 'BufNewFile', 'BufEnter' },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'bwpge/lualine-pretty-path',
    'nvim-lualine/lualine.nvim',
  },
  config = function()
    M.pretty_path_component = require 'lualine.components.pretty_path' {
      self = { section = 'x' },
      directories = {
        max_depth = 3,
      },
      highlights = {
        newfile = 'LazyProgressDone',
      },
    }

    M.helpers = require 'incline.helpers'

    require('incline').setup {
      window = {
        padding = 0,
        margin = { horizontal = 0 },
      },
      ignore = {
        filetypes = { 'alpha', 'neo-tree', 'snacks_dashboard' },
      },
      highlight = {
        groups = {
          InclineNormal = { guibg = 'none' },
          InclineNormalNC = { guibg = 'none' },
        },
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

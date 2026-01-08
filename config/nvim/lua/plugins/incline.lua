local M = {}

local sep = {
  spacer = ' ',
  bar = '│',
}

local function render_icons(props)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
  local ft_icon, ft_color = M.devicons.get_icon_color(filename)

  local result = {}

  if ft_icon then
    table.insert(result, { sep.spacer, ft_icon, sep.spacer, guibg = ft_color, guifg = M.helpers.contrast_color(ft_color) })
  end

  return result
end

local function render_harpoon(props)
  return vim.api.nvim_win_call(props.win, function()
    local result = M.harpoon_component:update_status(props.focused)
    local statusline = M.helpers.eval_statusline('%#lualine_c_inactive#' .. result)
    return statusline
  end)
end

local function render_pretty_path(props)
  return vim.api.nvim_win_call(props.win, function()
    local result = M.pretty_path_component:update_status(props.focused)
    local statusline = M.helpers.eval_statusline(result)
    if #statusline == 1 then
      statusline[1].group = 'StatusLineNC'
    end
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
  if vim.g.disable_autoformat then
    return { '󰉥', group = 'ErrorMsg' }
  elseif vim.b[props.buf].disable_autoformat then
    return { '󰉥', group = 'WarningMsg' }
  end

  return {}
end

local function render(props)
  local diag = render_diag(props)
  local icons = render_icons(props)
  local pretty_path = render_pretty_path(props)
  local extras = render_extras(props)
  local harpoon = render_harpoon(props)

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

  if #harpoon > 0 then
    table.insert(results, {
      { harpoon, sep.spacer, group = props.focused and 'StatusLine' or 'StatusLineNC' },
    })
  end

  return results
end

return {
  'b0o/incline.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    {
      'bwpge/lualine-pretty-path',
      dependencies = {
        'nvim-lualine/lualine.nvim',
      },
    },
    {
      'letieu/harpoon-lualine',
      dependencies = {
        {
          'ThePrimeagen/harpoon',
          branch = 'harpoon2',
          dependencies = {

            'nvim-lualine/lualine.nvim',
          },
        },
      },
    },
  },
  config = function()
    M.pretty_path_component = require 'lualine.components.pretty_path' {
      self = { section = 'x' },
      directories = {
        max_depth = 3,
      },
      highlights = {
        directory = 'Comment',
        filename = 'Bold',
      },
    }

    M.harpoon_component = require 'lualine.components.harpoon2' {
      self = { section = 'a' },
      icon = '',
      indicators = { '', '', '', '' },
      active_indicators = { '[a]', '[s]', '[d]', '[f]' },
      color_active = { fg = 'bold' },
      _separator = '',
    }

    M.helpers = require 'incline.helpers'
    M.devicons = require 'nvim-web-devicons'

    require('incline').setup {
      window = {
        padding = 0,
        margin = { horizontal = 0 },
      },
      ignore = {
        filetypes = { 'alpha', 'neo-tree', 'snacks_dashboard', 'oil' },
      },
      render = function(props)
        return render(props)
      end,
    }
  end,
}

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
  local pretty_path_component = require 'lualine.components.pretty_path' {
    self = { section = 'x' },
    directories = {
      max_depth = 4,
    },
    highlights = {
      newfile = 'LazyProgressDone',
    },
  }

  local helpers = require 'incline.helpers'
  local is_focused = vim.api.nvim_get_current_win() == props.win
  return helpers.eval_statusline(pretty_path_component:update_status(is_focused), { winid = props.win })
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

local function render(props)
  local diag = render_diag(props)
  local icons = render_icons(props)
  local pretty_path = render_pretty_path(props)

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

  return results
end

return {
  'b0o/incline.nvim',
  event = { 'BufRead', 'BufNewFile', 'BufEnter' },
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'bwpge/lualine-pretty-path',
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

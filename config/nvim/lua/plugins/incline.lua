local M = {}
local path_utils = require 'utils.path'

local sep = {
  spacer = ' ',
  bar = '│',
}

local function parse_codediff_buffer(bufname)
  local _, commit, filepath = bufname:match '^codediff://(.+)///([a-f0-9]+%^?)/(.+)$'

  if commit and filepath then
    local short_commit
    if commit:sub(-1) == '^' then
      short_commit = commit:sub(1, 8) .. '^'
    else
      short_commit = commit:sub(1, 8)
    end

    return {
      commit = commit,
      filepath = filepath,
      filename = vim.fn.fnamemodify(filepath, ':t'),
      short_commit = short_commit,
    }
  end
  return nil
end

local function render_icons(props)
  -- Use path_utils.get_icon_color to support custom icons
  local ft_icon, ft_color, custom_text = path_utils.get_icon_color(props.buf, M.devicons)

  local result = {}

  if ft_icon then
    local left_icon_sep = sep.spacer
    local right_icon_sep = sep.spacer

    if ft_icon == '' then
      right_icon_sep = sep.spacer .. sep.spacer
    end

    table.insert(result, { left_icon_sep, ft_icon, right_icon_sep, guibg = ft_color, guifg = M.helpers.contrast_color(ft_color) })
  end

  return result, custom_text
end

local function render_harpoon(props)
  return vim.api.nvim_win_call(props.win, function()
    local result = M.harpoon_component:update_status(props.focused)
    if result == nil or #result == 0 then
      return {}
    end
    local statusline = M.helpers.eval_statusline('%#lualine_c_inactive#' .. result)
    return statusline
  end)
end

local function render_path(props, custom_text)
  local bufname = vim.api.nvim_buf_get_name(props.buf)
  local buftype = vim.bo[props.buf].buftype

  local codediff_info = parse_codediff_buffer(bufname)
  if codediff_info then
    local hl_group = props.focused and 'Label' or 'StatusLineNC'
    return {
      { codediff_info.filename, group = hl_group },
      { sep.spacer },
      { codediff_info.short_commit, group = 'Comment' },
    }
  end

  if custom_text then
    local hl_group = props.focused and 'Label' or 'StatusLineNC'
    return {
      { custom_text, group = hl_group },
    }
  end

  if bufname ~= '' and buftype == '' then
    local unique_path = path_utils.get_unique_path(props.buf)

    local hl_group = props.focused and 'Label' or 'StatusLineNC'

    return {
      { unique_path, group = hl_group },
    }
  end

  -- Fallback to filename for special buffers
  local filename = vim.fn.fnamemodify(bufname, ':t')
  if filename == '' then
    filename = '[No Name]'
  end

  local hl_group = props.focused and 'Label' or 'StatusLineNC'

  return {
    { filename, group = hl_group },
  }
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
  local extras = {}
  local modified = vim.bo[props.buf].modified and '●' or ''

  if modified ~= '' then
    table.insert(extras, { modified, group = 'WarningMsg' })
  end

  if vim.g.disable_autoformat then
    table.insert(extras, { '󰉥', group = 'ErrorMsg' })
  elseif vim.b[props.buf].disable_autoformat then
    table.insert(extras, { '󰉥', group = 'WarningMsg' })
  end

  local zen = package.loaded['snacks'].zen
  if zen and zen.win and zen.win:valid() or false then
    table.insert(extras, { '', group = 'StatusLine' })
  end

  return extras
end

local function render(props)
  local diag = render_diag(props)
  local icons, custom_text = render_icons(props)
  local path = render_path(props, custom_text)
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

  table.insert(results, { sep.spacer, path, sep.spacer })

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
        unlisted_buffers = false,
        floating_wins = false,
        buftypes = function(bufnr, buftype)
          local ignored_filetypes = {
            'alpha',
            'neo-tree',
            'snacks_dashboard',
            'snacks_terminal',
            'snacks_notif',
            'terminal',
            'incline',
            'noice',
            'harpoon',
          }
          local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
          if filetype and vim.tbl_contains(ignored_filetypes, filetype) then
            return true
          end
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match '^codediff://' then
            return false
          end
          if filetype == 'codecompanion' then
            return false
          end
          local _, _, custom_text = path_utils.get_icon_color(bufnr, M.devicons)
          if custom_text then
            return false
          end
          return buftype ~= ''
        end,
        wintypes = function(winid, wintype)
          local zen = package.loaded['snacks'].zen
          if zen and zen.win and not zen.win.closed then
            return winid ~= zen.win.win
          end
          return wintype ~= ''
        end,
      },
      render = function(props)
        -- Hack for initial focused state
        -- Possibly related to: https://github.com/b0o/incline.nvim/issues/72
        if vim.api.nvim_get_current_buf() == props.buf and vim.api.nvim_get_current_win() == props.win and props.focused == false then
          props.focused = true
        end

        return render(props)
      end,
    }

    vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'WinClosed', 'TabEnter', 'FileType' }, {
      callback = function()
        path_utils.invalidate_cache()
        -- Refresh incline to handle codediff and other special buffers
        vim.schedule(function()
          require('incline').refresh()
        end)
      end,
    })
  end,
}

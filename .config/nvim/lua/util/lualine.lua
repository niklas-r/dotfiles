-- Borrowed shamelessley from Lazyvim and then modified
---@class custom.util.lualine
local M = {}

--- From: https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
--- @param trunc_width number trunctates component when screen width is less then trunc_width
--- @param trunc_len number truncates component to trunc_len number of chars
--- @param hide_width number hides component when window width is smaller then hide_width
--- @param no_ellipsis boolean whether to disable adding '...' at end after truncation
--- return function that can format the component accordingly
function M.trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
  return function(str)
    local win_width = vim.fn.winwidth(0)
    if hide_width and win_width < hide_width then
      return ''
    elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
      return str:sub(1, trunc_len) .. (no_ellipsis and '' or '…')
    end
    return str
  end
end

-- Show LSP status, borrowed from Heirline cookbook
-- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#lsp
function M.lsp_status_all()
  local haveServers = false
  local names = {}
  for _, server in pairs(vim.lsp.get_clients { bufnr = 0 }) do
    haveServers = true
    table.insert(names, server.name)
  end
  if not haveServers then
    return ''
  end
  if vim.g.custom_lualine_show_lsp_names then
    return ' ' .. table.concat(names, ',')
  end
  return ' '
end

-- Override 'encoding': Don't display if encoding is UTF-8.
function M.encoding_only_if_not_utf8()
  local ret, _ = (vim.bo.fenc or vim.go.enc):gsub('^utf%-8$', '')
  return ret
end

-- fileformat: Don't display if &ff is unix.
function M.fileformat_only_if_not_unix()
  local ret, _ = vim.bo.fileformat:gsub('^unix$', '')
  return ret
end

function M.selectionCount()
  local isVisualMode = vim.fn.mode():find '[Vv]'
  if not isVisualMode then
    return ''
  end
  local starts = vim.fn.line 'v'
  local ends = vim.fn.line '.'
  local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
  return tostring(lines) .. 'L ' .. tostring(vim.fn.wordcount().visual_chars) .. 'C'
end

---Return a custom lualine tabline section that integrates Harpoon marks.
function M.lualine_harpoon()
  local hp_keys = { 'a', 's', 'd', 'f' }
  local prev_file, prev_output, prev_mode, prev_count, hp

  return function()
    hp = hp or require 'harpoon'
    local hp_list = hp:list()
    local total_marks = hp_list:length()
    if total_marks == 0 then
      return ''
    end

    local current_file = vim.api.nvim_buf_get_name(0)
    local current_file_exp = vim.fn.expand '%'
    local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
    -- PERF: Same state returns the previous output
    if mode == prev_mode and (current_file == prev_file or current_file_exp == prev_file) and prev_count == total_marks then
      return prev_output
    end

    local hl_normal = mode == 'n' and '%#lualine_b_normal#'
      or mode == 'i' and '%#lualine_b_insert#'
      or mode == 'c' and '%#lualine_b_command#'
      or '%#lualine_b_visual#'

    -- Create custom highlight group with underline
    local base_hl_group = ('v' == mode or 'V' == mode or '' == mode) and 'lualine_transitional_lualine_a_visual_to_lualine_b_visual'
      or 'lualine_b_diagnostics_warn_normal'
    local underline_hl_group = 'lualine_harpoon_selected_' .. mode
    local base_hl = vim.api.nvim_get_hl(0, { name = base_hl_group })
    vim.api.nvim_set_hl(0, underline_hl_group, {
      fg = base_hl.fg,
      bg = base_hl.bg,
      underline = true,
    })

    local hl_selected = '%#' .. underline_hl_group .. '#'

    local output = '󰛢 ' .. hl_normal
    for index = 1, total_marks <= 4 and total_marks or 4 do
      local marked_file = hp_list.items[index].value
      -- FIXME: Sometimes the buffname is the full path and others the symlink...
      ---@diagnostic disable-next-line: param-type-mismatch
      if marked_file == current_file_exp or marked_file == current_file or current_file_exp:endswith(marked_file) or current_file:endswith(marked_file) then
        output = output .. hl_selected .. hp_keys[index] .. hl_normal
      else
        output = output .. hp_keys[index]
      end
    end

    prev_count = total_marks
    prev_file = current_file
    prev_mode = mode
    prev_output = output

    return output
  end
end

return M

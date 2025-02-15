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

return M

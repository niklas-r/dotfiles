-- Borrowed shamelessley from Lazyvim and then modified
---@class custom.util.lualine
local M = {}

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

local M = {}

---@param prop? string property to get. Defaults to "fg"
function M.get_hl_color(group, prop)
  prop = prop or 'fg'
  group = type(group) == 'table' and group or { group }
  ---@cast group string[]
  for _, g in ipairs(group) do
    local hl = vim.api.nvim_get_hl(0, { name = g, link = false, create = false })
    if hl[prop] then
      return string.format('#%06x', hl[prop])
    end
  end
end

return M

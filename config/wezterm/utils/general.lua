local M = {}

M.filter = function(tbl, callback)
  local filt_table = {}

  for i, v in ipairs(tbl) do
    if callback(v, i) then
      table.insert(filt_table, v)
    end
  end
  return filt_table
end

M.getDirNameFromPath = function(path)
  local parts = M.split(path, '/')
  return parts[#parts]
end

return M

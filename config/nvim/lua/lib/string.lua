---@param str string|number The substring to check for at the end of the string
---@return boolean True if the string ends with the specified substring, false otherwise
function string:endswith(str)
  ---@diagnostic disable-next-line: param-type-mismatch
  return self:sub(-#str) == str
end

return {}

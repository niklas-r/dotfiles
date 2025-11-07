local TOML = require 'utils.toml'

local M = {}

M.globalsPath = os.getenv 'HOME' .. '/.config/wezterm/globals.toml'
M.nvimPath = os.getenv 'HOME' .. '/.local/share/nvim'

M.readGlobals = function()
  local globals = M.readFromFile(M.globalsPath)
  -- NOTE: When wezterm.serde.toml_decode is available in stable builds, use it instead
  -- return wezterm.serde.toml_decode(globals)
  return TOML.parse(globals)
end

M.setGlobals = function(callback)
  local globals = M.readGlobals()
  callback(globals)
  -- NOTE: When wezterm.serde.toml_encode is available in stable builds, use it instead
  -- M.writeToFile(M.globalsPath, wezterm.serde.toml_encode(globals))
  M.writeToFile(M.globalsPath, TOML.encode(globals))
end

M.readFromFile = function(path)
  local file = assert(io.open(path, 'r'))
  local content = file:read '*a'
  file:close()
  return content
end

M.writeToFile = function(path, content)
  local file = assert(io.open(path, 'w'))
  file:write(content)
  file:close()
end

return M

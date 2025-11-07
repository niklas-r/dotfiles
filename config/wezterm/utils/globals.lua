local TOML = require 'utils.toml'

local M = {}

M.globals_path = os.getenv 'HOME' .. '/.config/wezterm/globals.toml'
M.nvim_path = os.getenv 'HOME' .. '/.local/share/nvim'

M.read_globals = function()
  local globals = M.read_from_file(M.globals_path)
  -- NOTE: When wezterm.serde.toml_decode is available in stable builds, use it instead
  -- return wezterm.serde.toml_decode(globals)
  return TOML.parse(globals)
end

M.set_globals = function(callback)
  local globals = M.read_globals()
  callback(globals)
  -- NOTE: When wezterm.serde.toml_encode is available in stable builds, use it instead
  -- M.writeToFile(M.globalsPath, wezterm.serde.toml_encode(globals))
  M.write_to_file(M.globals_path, TOML.encode(globals))
end

M.read_from_file = function(path)
  local file = assert(io.open(path, 'r'))
  local content = file:read '*a'
  file:close()
  return content
end

M.write_to_file = function(path, content)
  local file = assert(io.open(path, 'w'))
  file:write(content)
  file:close()
end

return M

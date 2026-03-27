local wezterm = require 'wezterm' ---@type Wezterm

local M = {}

M.wezterm_path = os.getenv 'HOME' .. '/.config/wezterm'
M.globals_path = M.wezterm_path .. '/globals.toml'
M.nvim_path = os.getenv 'HOME' .. '/.local/share/nvim'

M.read_globals = function()
  local globals = M.read_from_file(M.globals_path)
  return wezterm.serde.toml_decode(globals)
end

M.set_globals = function(callback)
  local globals = M.read_globals()
  callback(globals)
  M.write_to_file(M.globals_path, wezterm.serde.toml_encode(globals))
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

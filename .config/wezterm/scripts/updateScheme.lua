#!/opt/homebrew/bin/lua

local u = dofile(os.getenv 'HOME' .. '/.config/wezterm/utils.lua')

local lua = u.readLuaObject(u.globalsPath)
lua.colorscheme = tostring(arg[1])
u.writeLuaObject(u.globalsPath, lua)

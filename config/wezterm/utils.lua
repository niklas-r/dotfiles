local wez = require 'wezterm'
local G = require 'globals'
local M = {}

M.globalsPath = os.getenv 'HOME' .. '/.config/wezterm/globals.lua'

function M.readLuaObject(filePath)
  local file = assert(loadfile(filePath))
  return file()
end

function M.writeLuaObject(filePath, luaObject)
  local function tableToString(tbl, indent)
    indent = indent or ''
    local result = '{\n'
    local nextIndent = indent .. '  '
    for k, v in pairs(tbl) do
      local keyStr
      if type(k) == 'string' and k:match '^%a[%w_]*$' then
        keyStr = k -- Use key as-is without brackets if it's a valid identifier
      else
        keyStr = '[' .. tostring(k) .. ']'
      end

      if type(v) == 'table' then
        result = result .. nextIndent .. keyStr .. ' = ' .. tableToString(v, nextIndent) .. ',\n'
      else
        local valueStr = (type(v) == 'string') and '"' .. v .. '"' or tostring(v)
        result = result .. nextIndent .. keyStr .. ' = ' .. valueStr .. ',\n'
      end
    end
    result = result .. indent .. '}'
    return result
  end

  local file = assert(io.open(filePath, 'w'))
  file:write('return ' .. tableToString(luaObject) .. '\n')
  file:close()
end

---@param key "surface" | "foreground" | "background" | "tab_bar_bg" | "black" | "red" | "green" | "yellow" | "blue" | "magenta" | "cyan" | "white" | "black_bright" | "red_bright" | "green_bright" | "yellow_bright" | "blue_bright" | "magenta_bright" | "cyan_bright" | "white_bright"
---@return string
function M.getColorByKey(key)
  local current_scheme = wez.color.get_builtin_schemes()[G.colorscheme]

  local surface = current_scheme.cursor and current_scheme.cursor.bg or current_scheme.ansi[1]

  if string.find(G.colorscheme, 'Catppuccin') then
    surface = current_scheme.tab_bar.inactive_tab_edge
  end

  local key_to_color = {
    surface = surface,
    foreground = current_scheme.foreground,
    background = current_scheme.background,
    black = current_scheme.ansi[1],
    red = current_scheme.ansi[2],
    green = current_scheme.ansi[3],
    yellow = current_scheme.ansi[4],
    blue = current_scheme.ansi[5],
    magenta = current_scheme.ansi[6],
    cyan = current_scheme.ansi[7],
    white = current_scheme.ansi[8],
    black_bright = current_scheme.brights[1],
    red_bright = current_scheme.brights[2],
    green_bright = current_scheme.brights[3],
    yellow_bright = current_scheme.brights[4],
    blue_bright = current_scheme.brights[5],
    magenta_bright = current_scheme.brights[6],
    cyan_bright = current_scheme.brights[7],
    white_bright = current_scheme.brights[8],
    tab_bar_bg = current_scheme.tab_bar and current_scheme.tab_bar.inactive_tab and current_scheme.tab_bar.inactive_tab.bg_color or current_scheme.background,
  }

  return key_to_color[key]
end

function M.getCommandIcon(cmd)
  if cmd == 'nvim' then
    return wez.nerdfonts.linux_neovim
  elseif string.find(cmd, 'git') then
    return wez.nerdfonts.oct_git_branch
  end
  return wez.nerdfonts.fa_code
end

M.filter = function(tbl, callback)
  local filt_table = {}

  for i, v in ipairs(tbl) do
    if callback(v, i) then
      table.insert(filt_table, v)
    end
  end
  return filt_table
end

return M

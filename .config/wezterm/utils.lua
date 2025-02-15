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

function M.getColorByKey(wez, window, key)
  local current_scheme = wez.color.get_builtin_schemes()[window:effective_config().color_scheme]

  local key_to_color = {
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
  }

  return key_to_color[key]
end

return M

local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}

M.scriptsPath = os.getenv 'HOME' .. '/.config/wezterm/scripts'

-- fzf switcher which opens in a right split and executes a command
M.fzfSwitcher = function(window, pane, script, command)
  -- execute fzf with update script on every cursor move
  local fzfCommand = "fzf --color=bg+:-1 --reverse  --preview-window=down,1 --preview='" .. script .. " {}'"

  window:perform_action(
    act.SplitPane {
      direction = 'Right',
      command = {
        args = {
          'zsh',
          '-c',
          command .. fzfCommand,
        },
      },
      size = { Percent = 25 },
    },
    pane
  )
end

M.font_switcher = function(window, pane)
  -- get system fonts by family name including only monospaced fonts, format and sort them
  local fontsCommand = "fc-list :spacing=100 family | grep -v '^\\.' | cut -d ',' -f1 | sort -u | "

  M.fzfSwitcher(window, pane, M.scriptsPath .. '/updateFont.lua', fontsCommand)
end

M.theme_switcher = function(window, pane)
  -- get builtin wezterm color schemes
  local builtinSchemes = wezterm.get_builtin_color_schemes()

  -- build a new table from the builtin wezterm color schemes names
  local schemes = {}

  for key, _ in pairs(builtinSchemes) do
    table.insert(schemes, tostring(key))
  end

  -- sort them alphabetically
  table.sort(schemes, function(c1, c2)
    return c1 < c2
  end)

  -- build the command from schemes table to be passed to fzf
  local schemesCommand = 'echo -e "' .. table.concat(schemes, '\n') .. '" | '

  M.fzfSwitcher(window, pane, M.scriptsPath .. '/updateScheme.lua', schemesCommand)
end

return M

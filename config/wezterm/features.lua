local wezterm = require 'wezterm'
local utils = require 'utils.general'
local picker = require 'utils.picker'
local globals = require 'utils.globals'
local colors = require 'utils.colors'

local M = {}

M.themes = function()
  return wezterm.action_callback(function(window, pane)
    local choices = {}

    local schemes = wezterm.get_builtin_color_schemes()
    local custom_schemes_path = wezterm.glob(wezterm.config_dir .. '/colors/*')

    -- loop over builtin schemes
    for scheme, _ in pairs(schemes) do
      table.insert(choices, { label = tostring(scheme) })
    end

    -- sort choices list
    table.sort(choices, function(c1, c2)
      return c1.label < c2.label
    end)

    local action = wezterm.action_callback(function(_, _, _, label)
      if label then
        globals.setGlobals(function(G)
          G.colorscheme = label
        end)
        colors.set_nvim_color_scheme(label)
      end
    end)

    local opts = {
      window = window,
      pane = pane,
      choices = choices,
      title = wezterm.format {
        { Attribute = { Underline = 'Single' } },
        { Foreground = { AnsiColor = 'Green' } },
        { Text = 'Choose a theme! 🎨' },
      },
      action = action,
    }

    picker.pick(opts)
  end)
end

M.fonts = function()
  return wezterm.action_callback(function(window, pane)
    local choices = {}

    local _, stdout, _ = wezterm.run_child_process { 'zsh', '-ic', 'fc-list :spacing=mono family' }

    local list = wezterm.split_by_newlines(stdout)

    -- loop over builtin schemes
    for _, font in pairs(list) do
      if string.sub(font, 1, 1) ~= '.' then
        if font:find ',' then
          -- split and take first part
          local first = font:match '([^,]+)'
          table.insert(choices, { label = tostring(first) })
        else
          table.insert(choices, { label = tostring(font) })
        end
      end
    end

    -- sort choices list
    table.sort(choices, function(c1, c2)
      return c1.label < c2.label
    end)

    local action = wezterm.action_callback(function(_, _, _, label)
      if label then
        globals.setGlobals(function(G)
          G.font = label
        end)
      end
    end)

    local opts = {
      window = window,
      pane = pane,
      choices = choices,
      title = wezterm.format {
        { Attribute = { Underline = 'Single' } },
        { Foreground = { AnsiColor = 'Green' } },
        { Text = 'Choose a font! ✏️  ' },
      },
      action = action,
    }

    picker.pick(opts)
  end)
end

M.kill_workspace = function(workspace)
  local success, stdout = wezterm.run_child_process { '/opt/homebrew/bin/wezterm', 'cli', 'list', '--format=json' }

  if success then
    local json = wezterm.json_parse(stdout)
    if not json then
      return
    end

    local workspace_panes = utils.filter(json, function(p)
      return p.workspace == workspace
    end)

    for _, p in ipairs(workspace_panes) do
      wezterm.run_child_process {
        '/opt/homebrew/bin/wezterm',
        'cli',
        'kill-pane',
        '--pane-id=' .. p.pane_id,
      }
    end
  end
end

return M

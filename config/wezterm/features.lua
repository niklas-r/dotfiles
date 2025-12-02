local wezterm = require 'wezterm'
local utils = require 'utils.general'
local picker = require 'utils.picker'
local globals = require 'utils.globals'
local colors = require 'utils.colors'

local M = {}

M.themes = function(set_nvim_theme)
  return wezterm.action_callback(function(window, pane)
    local choices = {}

    local schemes = wezterm.get_builtin_color_schemes()

    -- loop over builtin schemes
    for scheme, _ in pairs(schemes) do
      table.insert(choices, { label = tostring(scheme) })
    end

    if set_nvim_theme then
      choices = utils.filter(choices, function(choice)
        return colors.is_nvim_theme(choice.label)
      end)
    end

    table.sort(choices, function(c1, c2)
      return c1.label < c2.label
    end)

    local action = wezterm.action_callback(function(_, _, _, label)
      if label then
        globals.set_globals(function(G)
          G.colorscheme = label
        end)
        if set_nvim_theme then
          colors.set_nvim_color_scheme(label)
        end
      end
    end)

    local opts = {
      window = window,
      pane = pane,
      choices = choices,
      title = wezterm.format {
        { Attribute = { Underline = 'Single' } },
        { Foreground = { AnsiColor = 'Green' } },
        { Text = '  🌈 Choose a theme:  ' },
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
        globals.set_globals(function(G)
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
        { Text = 'Choose a font' },
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

M.get_next_meeting = function()
  local icalbuddy_path = nil
  for _, path in ipairs { '/opt/homebrew/bin/icalBuddy', '/usr/local/bin/icalBuddy' } do
    local success, _, _ = wezterm.run_child_process { 'test', '-x', path }
    if success then
      icalbuddy_path = path
      break
    end
  end

  if not icalbuddy_path then
    return nil
  end

  local cmd_success, stdout, _ = wezterm.run_child_process {
    icalbuddy_path,
    '-n',
    '-ea',
    '-npn',
    '-nc',
    '-li',
    '1',
    '-iep',
    'datetime,title,location',
    '-po',
    'datetime,title,location',
    '-ps',
    '| | (|',
    '-tf',
    '%H:%M',
    '-b',
    '',
    '-ss',
    '',
    'eventsToday',
  }

  if cmd_success and stdout and stdout ~= '' then
    local result = stdout:match '^%s*(.-)%s*$'

    if result and result ~= '' then
      result = result:gsub('Microsoft Teams Meeting', 'Teams')

      -- Simplify Teams meeting format: extract title and location only
      local before_paren, location = result:match '(.-)%(Teams;%s*(.*)$'
      if before_paren and location then
        result = before_paren .. '(' .. location .. ')'
      end

      -- Ensure closing parenthesis if there's an opening one without a closing one
      if result:find('(', 1, true) and not result:find(')', 1, true) then
        result = result .. ')'
      end

      return result
    end
  end

  wezterm.log_info 'No upcoming meetings found'
  return nil
end

return M

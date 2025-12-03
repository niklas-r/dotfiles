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
  local icalpal_path = nil
  for _, path in ipairs { '/opt/homebrew/bin/icalPal', '/usr/local/bin/icalPal' } do
    local success, _, _ = wezterm.run_child_process { 'test', '-x', path }
    if success then
      icalpal_path = path
      break
    end
  end

  if not icalpal_path then
    return nil
  end

  local cmd_success, stdout, _ = wezterm.run_child_process {
    icalpal_path,
    '-n',
    '-o',
    'json',
    'eventsToday',
  }

  if cmd_success and stdout and stdout ~= '' then
    local json = wezterm.json_parse(stdout)

    if json and #json > 0 then
      local event = json[1]
      local result = ''

      -- Extract start and end time from Unix timestamps and format to local time
      if event.sseconds then
        local start_time = os.date('%H:%M', event.sseconds)
        if start_time then
          result = start_time
          -- Add end time if available
          if event.eseconds then
            local end_time = os.date('%H:%M', event.eseconds)
            if end_time then
              result = result .. '-' .. end_time
            end
          end
        end
      end

      -- Add title
      if event.title then
        if result ~= '' then
          result = result .. ' | '
        end
        result = result .. event.title
      end

      -- Add location if available
      if event.location and event.location ~= '' then
        local location = event.location
        local is_teams = event.conference_url_detected and event.conference_url_detected:find 'teams.microsoft.com'

        if is_teams then
          -- For Teams meetings, extract physical location if present or just use "Teams"
          local physical_location = location:match 'Teams;%s*(.+)' or location:match ';%s*(.+)'
          if physical_location then
            location = physical_location
          elseif location:find 'Microsoft Teams' or location:find 'Teams' then
            location = 'Teams'
          end
        end

        -- Strip address details (everything in parentheses)
        local location_name = location:match '^([^%(]+)'
        if location_name then
          location = location_name:match '^%s*(.-)%s*$' -- trim whitespace
        end

        result = result .. ' | (' .. location .. ')'
      end

      return result
    end
  end

  return nil
end

return M

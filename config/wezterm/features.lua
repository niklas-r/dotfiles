---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require 'wezterm' ---@type Wezterm
local utils = require 'utils.general'
local picker = require 'utils.picker'
local globals = require 'utils.globals'
local colors = require 'utils.colors'

local M = {}

M.themes = function(set_nvim_theme)
  return wezterm.action_callback(function(window, pane)
    local choices = {}

    local schemes = wezterm.color.get_builtin_schemes()

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
    '-n', -- Only upcoming events.
    '--ic', -- Use calendar
    'Calendar', -- with name "Calendar".
    '--li', -- Limit events
    '1', -- to 1.
    '--ea', -- Exclude all-day events.
    -- '--so', -- Sort by
    -- 'start_date',
    '-o',
    'json',
    'eventsToday',
  }

  if cmd_success and stdout and stdout ~= '' then
    local json = wezterm.json_parse(stdout)

    if json and #json > 0 then
      local event = json[1]
      local meeting = {
        time = nil,
        start_time = nil,
        end_time = nil,
        start_timestamp = nil,
        title = nil,
        location = nil,
        is_teams = false,
      }

      -- Parse timestamp
      -- For recurring events, icalPal has a bug where:
      -- - sseconds has the correct TIME but wrong DATE (from original occurrence)
      -- - sctime has the correct DATE but sometimes wrong TIME
      -- Solution: Use time from sseconds, date from sctime or today
      if event.has_recurrences == 1 and event.sseconds and event.sctime then
        -- Get the time components from sseconds (correct time)
        local time_table = os.date('*t', event.sseconds)
        local hour, min, sec = time_table.hour, time_table.min, time_table.sec

        -- Get the date from sctime (correct date)
        local year, month, day = event.sctime:match '(%d+)%-(%d+)%-(%d+)'

        if year and hour then
          meeting.start_timestamp = os.time {
            year = tonumber(year) or 0,
            month = tonumber(month) or 0,
            day = tonumber(day) or 0,
            hour = hour,
            min = min,
            sec = sec,
          }
          meeting.start_time = string.format('%02d:%02d', hour, min)
        end
      elseif event.sseconds then
        -- Non-recurring events: sseconds is reliable
        meeting.start_timestamp = event.sseconds
        meeting.start_time = os.date('%H:%M', event.sseconds)
      end

      -- Parse end time
      if event.has_recurrences == 1 and event.eseconds and event.ectime then
        -- Same fix for end time: use time from eseconds, date from ectime
        local time_table = os.date('*t', event.eseconds)
        meeting.end_time = string.format('%02d:%02d', time_table.hour, time_table.min)
      elseif event.ectime then
        local hour, min = event.ectime:match '(%d+):(%d+):(%d+)'
        if hour then
          meeting.end_time = string.format('%02d:%02d', tonumber(hour), tonumber(min))
        end
      elseif event.eseconds and meeting.start_time then
        meeting.end_time = os.date('%H:%M', event.eseconds)
      end

      -- Build time display
      if meeting.start_time then
        meeting.time = meeting.start_time
        if meeting.end_time then
          meeting.time = meeting.time .. '-' .. meeting.end_time
        end
      end

      if event.title then
        meeting.title = event.title:match '^%s*(.-)%s*$'
      end

      if event.location and event.location ~= '' then
        local location = event.location
        meeting.is_teams = event.conference_url_detected and event.conference_url_detected:find 'teams.microsoft.com' or location:find 'Microsoft Teams'

        if meeting.is_teams then
          -- For Teams meetings, extract physical location if present or just use "Teams"
          local physical_location = location:match ';%s*(.+)'
          if physical_location then
            location = physical_location
          else
            location = 'Teams'
          end
        end

        -- Strip address details (everything in parentheses)
        local location_name = location:match '^([^%(]+)'
        if location_name then
          location = location_name:match '^%s*(.-)%s*$' -- trim whitespace
        end

        meeting.location = location
      end

      return meeting
    end
  end

  return nil
end

return M

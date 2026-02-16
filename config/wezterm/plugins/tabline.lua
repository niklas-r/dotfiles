---@diagnostic disable-next-line: assign-type-mismatch
local wez = require 'wezterm' ---@type Wezterm
local colors = require 'utils.colors'
local globals = require 'utils.globals'
local tabline = wez.plugin.require 'https://github.com/michaelbrusegard/tabline.wez' ---@type TablineWez
local features = require 'features'

local G = globals.read_globals()

return {
  tabline = tabline,
  setup = function()
    local function getTabComponents(isActive)
      return {
        'index',
        { 'process', padding = { left = 0, right = 0 }, icons_only = true },
        {
          'parent',
          padding = 0,
          max_length = isActive and 15 or 5,
          cond = function(tab)
            return tab.tab_title == ''
          end,
          fmt = function(output)
            return output .. '/'
          end,
        },
        {
          'cwd',
          padding = { left = 0, right = 1 },
          max_length = isActive and 20 or 10,

          cond = function(tab)
            return tab.tab_title == ''
          end,
        },
        {
          'tab',
          icon = '',
          padding = { left = 0, right = 1 },
          max_length = 35,
          cond = function(tab)
            return #tab.tab_title > 1
          end,
        },
        {
          'output',
          cond = function(tab)
            if isActive then
              return false
            end

            for _, pane in ipairs(tab.panes) do
              if pane.has_unseen_output then
                return true
              end
            end

            return false
          end,
        },
        { 'zoomed', padding = 0 },
      }
    end

    local primary_color = colors.get_color_by_key 'blue'
    if string.find(G.colorscheme:lower(), 'rose') then
      primary_color = colors.get_color_by_key 'cyan'
    end

    local mode_colors = {
      normal_mode = {
        a = { fg = colors.get_color_by_key 'tab_bar_bg', bg = primary_color },
        b = { fg = primary_color, bg = colors.get_color_by_key 'surface' },
        c = { fg = colors.get_color_by_key 'foreground', bg = colors.get_color_by_key 'tab_bar_bg' },
      },
      copy_mode = {
        a = { fg = colors.get_color_by_key 'tab_bar_bg', bg = colors.get_color_by_key 'yellow' },
        b = { fg = colors.get_color_by_key 'yellow', bg = colors.get_color_by_key 'surface' },
        c = { fg = colors.get_color_by_key 'foreground', bg = colors.get_color_by_key 'tab_bar_bg' },
      },
      search_mode = {
        a = { fg = colors.get_color_by_key 'tab_bar_bg', bg = colors.get_color_by_key 'green' },
        b = { fg = colors.get_color_by_key 'green', bg = colors.get_color_by_key 'surface' },
        c = { fg = colors.get_color_by_key 'foreground', bg = colors.get_color_by_key 'tab_bar_bg' },
      },
      leader_mode = {
        a = { fg = colors.get_color_by_key 'tab_bar_bg', bg = colors.get_color_by_key 'red' },
        b = { fg = colors.get_color_by_key 'red', bg = colors.get_color_by_key 'surface' },
        c = { fg = colors.get_color_by_key 'foreground', bg = colors.get_color_by_key 'tab_bar_bg' },
      },
      tab = {
        active = {
          fg = primary_color,
          bg = colors.get_color_by_key 'background',
        },
        inactive = {
          fg = colors.get_color_by_key 'foreground',
          bg = colors.get_color_by_key 'tab_bar_bg',
        },
        inactive_hover = {
          fg = colors.get_color_by_key 'foreground',
          bg = colors.get_color_by_key 'surface',
        },
      },
    }

    local function left_separator()
      return wez.nerdfonts.ple_left_half_circle_thick
    end
    local function right_separator()
      return wez.nerdfonts.ple_right_half_circle_thick
    end

    ---@param output string
    ---@param window table -- Wezterm window object
    ---@param what 'fg'|'bg'|'both'|'fg-inverse'|'bg-inverse'|'both-inverse'
    ---@param fg_section 'a'|'b'|'c'
    ---@param bg_section? 'a'|'b'|'c'
    local function mode_formatter(output, window, what, fg_section, bg_section)
      local key_table = window:active_key_table()
      local leader = window:leader_is_active()

      local mode = 'normal_mode'
      if leader then
        mode = 'leader_mode'
      elseif type(key_table) == 'string' then
        mode = key_table
      end

      local mode_color = mode_colors[mode]

      if bg_section == nil then
        bg_section = fg_section
      end

      local fg = 'fg'
      local bg = 'bg'
      if what == 'fg-inverse' or what == 'both-inverse' then
        fg = 'bg'
      end
      if what == 'bg-inverse' or what == 'both-inverse' then
        bg = 'fg'
      end
      return wez.format {
        { Foreground = { Color = mode_color[fg_section][fg] } },
        { Background = { Color = mode_color[bg_section][bg] } },
        { Text = output },
      }
    end

    local lastMeetingCheck = 0
    local lastMeetingData = nil
    local lastMeetingCheckInterval = 10

    local function meeting_component(window)
      local now = os.time()

      local teams_icon = wez.nerdfonts.md_microsoft_teams
      local meeting_icon = wez.nerdfonts.md_account_group
      local no_meeting_icon = wez.nerdfonts.md_coffee

      local icon = no_meeting_icon
      local display_text = 'No more meetings'

      if now - lastMeetingCheck > lastMeetingCheckInterval then
        lastMeetingData = features.get_next_meeting()
        lastMeetingCheck = now
      end

      local meeting = lastMeetingData

      if meeting then
        icon = meeting.is_teams and teams_icon or meeting_icon

        -- Build display text
        local parts = {}
        if meeting.time then
          local time_display = meeting.time

          -- Add countdown if meeting is within 1 hour
          if meeting.start_timestamp then
            local diff_seconds = meeting.start_timestamp - os.time()

            if diff_seconds > 0 and diff_seconds <= 3600 then
              local minutes = math.ceil(diff_seconds / 60)
              time_display = time_display .. ' (in ' .. minutes .. 'm)'
            elseif diff_seconds < 0 and diff_seconds >= -3600 then
              -- Meeting started within the last hour
              local minutes = math.ceil(-diff_seconds / 60)
              time_display = time_display .. ' (started ' .. minutes .. 'm ago)'
            end
          end

          table.insert(parts, time_display)
        end
        if meeting.title ~= nil then
          local title = meeting.title
          local max_title_length = 20
          if title ~= nil and #title > max_title_length then
            title = title:sub(1, max_title_length):match '^%s*(.-)%s*$' .. '...'
          end
          table.insert(parts, title)
        end
        if meeting.location then
          table.insert(parts, '(' .. meeting.location .. ')')
        end
        display_text = table.concat(parts, ' | ')
      end

      return mode_formatter(' ' .. icon .. ' ' .. display_text .. ' ', window, 'both', 'b')
    end

    tabline.setup {
      options = {
        icons_enabled = true,
        theme = G.colorscheme,
        theme_overrides = mode_colors,
        color_overrides = {},
        section_separators = {
          left = '',
          right = '',
        },
        component_separators = {
          left = '',
          right = '',
        },
        tab_separators = {
          left = wez.nerdfonts.ple_right_half_circle_thick,
          right = wez.nerdfonts.ple_left_half_circle_thick,
        },
      },
      sections = {
        battery_to_icon = {
          empty = { wez.nerdfonts.fa_battery_empty, color = { fg = colors.get_color_by_key 'red' } },
          quarter = { wez.nerdfonts.fa_battery_quarter, color = { fg = colors.get_color_by_key 'yellow' } },
          half = wez.nerdfonts.fa_battery_half,
          three_quarters = wez.nerdfonts.fa_battery_three_quarters,
          full = wez.nerdfonts.fa_battery_full,
        },
        tabline_a = {
          {
            'mode',
            padding = 0,
            fmt = function(_, window)
              return mode_formatter(left_separator(), window, 'both-inverse', 'a')
            end,
          },
          {
            'mode',
            padding = 0,
            fmt = function(output, window)
              if window:leader_is_active() then
                return mode_formatter(' LEADER ', window, 'both', 'a')
              end
              return mode_formatter(' ' .. output .. ' ', window, 'both', 'a')
            end,
          },
        },
        tabline_b = {
          {
            'workspace',
            padding = 0,
            icon = '',
            fmt = function(output, window)
              return mode_formatter(' ' .. wez.nerdfonts.cod_terminal_tmux .. ' ' .. output .. ' ', window, 'both', 'b')
            end,
          },
          {
            'workspace',
            icon = '',
            padding = 0,
            fmt = function(_, window)
              return mode_formatter(right_separator(), window, 'fg-inverse', 'b', 'c')
            end,
          },
        },
        tabline_c = { ' ' },
        tab_active = getTabComponents(true),
        tab_inactive = getTabComponents(false),
        tabline_x = { 'ram', 'cpu' },
        tabline_y = {
          {
            'datetime',
            icons_enabled = false,
            padding = 0,
            fmt = function(_, window)
              return mode_formatter(left_separator(), window, 'fg-inverse', 'b', 'c')
            end,
          },
          meeting_component,
          {
            'datetime',
            icons_enabled = false,
            padding = 0,
            fmt = function(output, window)
              return mode_formatter(' ' .. wez.nerdfonts.md_clock_time_five_outline .. ' ' .. output .. ' ', window, 'both', 'b')
            end,
          },
          {
            'battery',
            icons_enabled = false,
            padding = 0,
            fmt = function(output, window)
              return mode_formatter(' ' .. wez.nerdfonts.fa_battery_full .. ' ' .. output .. ' ', window, 'both', 'b')
            end,
          },
        },
        tabline_z = {
          {
            'hostname',
            padding = 0,
            fmt = function(output, window)
              return mode_formatter(' ' .. output .. ' ', window, 'both', 'a')
            end,
          },
          {
            'hostname',
            padding = 0,
            fmt = function(_, window)
              return mode_formatter(right_separator(), window, 'both-inverse', 'a')
            end,
          },
        },
      },
      extensions = {},
    }
  end,
}

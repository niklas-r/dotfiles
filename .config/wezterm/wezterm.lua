local wezterm = require 'wezterm'
local act = wezterm.action
local features = require 'features'
local utils = require 'utils'
local G = require 'globals'

local config = wezterm.config_builder()

-- Dark mode not working with current impementation of theme switcher
-- local function scheme_for_appearance(appearance)
--   if appearance:find 'Dark' then
--     return G.dark_colorscheme
--   else
--     return G.light_colorscheme
--   end
-- end
--
-- wezterm.on('window-config-reloaded', function(window, pane)
--   local overrides = window:get_config_overrides() or {}
--   local appearance = window:get_appearance()
--   local scheme = scheme_for_appearance(appearance)
--   if overrides.color_scheme ~= scheme then
--     overrides.color_scheme = scheme
--     window:set_config_overrides(overrides)
--   end
-- end)

-- Fonts

local font = wezterm.font_with_fallback { { family = G.font } }
config.font = font
config.font_rules = { { intensity = 'Bold', font = font }, { intensity = 'Normal', font = font } }
config.font_size = 14

-- Disable weird behavior for left alt
config.send_composed_key_when_left_alt_is_pressed = true

-- Window
config.window_background_opacity = G.opacity
config.macos_window_background_blur = 50
config.window_padding = G.padding
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'AlwaysPrompt'
config.adjust_window_size_when_changing_font_size = false
-- config.window_frame = { font = wezterm.font_with_fallback { family = G.font, weight = 400 } }

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 0.24,
  brightness = 0.5,
}

-- Cursor
config.hide_mouse_cursor_when_typing = true

-- Workspaces
config.default_workspace = 'main'

-- Color scheme
config.color_scheme = G.colorscheme

-- Keys
config.leader = { key = 'phys:Space', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- Send keycode for leader when pressing leader twice
  { key = config.leader.key, mods = 'LEADER|' .. config.leader.mods, action = act.SendKey { key = config.leader.key, mods = config.leader.mods } },
  { key = 'c', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = 's', mods = 'LEADER', action = act.QuickSelect },
  { key = 'phys:Space', mods = 'LEADER|CTRL', action = act.ActivateCommandPalette },

  -- Switchers
  { key = 'k', mods = 'LEADER', action = wezterm.action_callback(features.theme_switcher) },
  { key = 'f', mods = 'LEADER', action = wezterm.action_callback(features.font_switcher) },

  -- Pane keybindings
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CMD|SHIFT', action = act.CloseCurrentPane { confirm = true } },
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'o', mods = 'LEADER', action = act.RotatePanes 'Clockwise' },
  -- We can make separate keybindings for resizing panes
  -- But Wezterm offers custom "mode" in the name of "KeyTable"
  {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false },
  },

  -- Tab keybindings
  { key = 't', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = '[', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'n', mods = 'LEADER', action = act.ShowTabNavigator },
  {
    key = 'e',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Renaming Tab Title...:' },
      },
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  -- Key table for moving tabs around
  { key = 'm', mods = 'LEADER', action = act.ActivateKeyTable { name = 'move_tab', one_shot = false } },
  -- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
  { key = '{', mods = 'LEADER', action = act.MoveTabRelative(-1) },
  { key = '}', mods = 'LEADER', action = act.MoveTabRelative(1) },

  -- Lastly, workspace
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i - 1),
  })
end

config.key_tables = {
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
  move_tab = {
    { key = 'h', action = act.MoveTabRelative(-1) },
    { key = 'j', action = act.MoveTabRelative(-1) },
    { key = 'k', action = act.MoveTabRelative(1) },
    { key = 'l', action = act.MoveTabRelative(1) },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
}

-- Tab bar
-- I don't like the look of "fancy" tab bar
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
config.tab_max_width = 32

wezterm.on('update-status', function(window, pane)
  -- Workspace name
  local stat = window:active_workspace()
  local stat_color = utils.getColorByKey(wezterm, window, 'red')
  local stat_icon = wezterm.nerdfonts.oct_table

  -- It's a little silly to have workspace name all the time
  -- Utilize this to display LDR or current key table name
  if window:active_key_table() then
    -- TODO:change stat_icon based on which active key table it is
    stat = wezterm.pad_right(window:active_key_table(), string.len(stat))
    stat_color = utils.getColorByKey(wezterm, window, 'green')
  elseif window:leader_is_active() then
    stat = wezterm.pad_right('LDR', string.len(stat))
    stat_color = utils.getColorByKey(wezterm, window, 'magenta')
    stat_icon = wezterm.nerdfonts.oct_rocket
  end

  local basename = function(s)
    -- Nothing a little regex can't fix
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
  end

  -- Current working directory
  local cwd = pane:get_current_working_dir()
  if cwd then
    if type(cwd) == 'userdata' then
      -- Wezterm introduced the URL object in 20240127-113634-bbcac864
      ---@diagnostic disable-next-line: undefined-field
      cwd = basename(cwd.file_path)
    else
      -- 20230712-072601-f4abf8fd or earlier version
      cwd = basename(cwd)
    end
  else
    cwd = nil
  end

  -- Current command
  local cmd = pane:get_foreground_process_name()
  -- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
  cmd = cmd and basename(cmd) or nil

  -- Time
  local time = wezterm.strftime '%H:%M'

  -- user
  local username = os.getenv 'USER' or os.getenv 'LOGNAME' or os.getenv 'USERNAME'

  -- Battery info
  local bat = wezterm.battery_info()
  local has_battery = bat ~= nil and #bat > 0
  local bat_percent
  local bat_icon
  local bat_color = ''
  local bat_icons = {
    [25] = wezterm.nerdfonts.fa_battery_quarter,
    [50] = wezterm.nerdfonts.fa_battery_half,
    [75] = wezterm.nerdfonts.fa_battery_three_quarters,
    [100] = wezterm.nerdfonts.fa_battery_full,
    Unknown = wezterm.nerdfonts.fa_battery_empty,
  }

  if has_battery then
    local b = bat[1]
    bat_percent = string.format('%.0f%%', b.state_of_charge * 100)
    bat_icon = bat_icons.Unknown

    if b.state == 'Charging' then
      bat_color = utils.getColorByKey(wezterm, window, 'green')
    elseif b.state_of_charge < 0.25 then
      bat_color = utils.getColorByKey(wezterm, window, 'yellow')
    elseif b.state_of_charge < 0.1 then
      bat_color = utils.getColorByKey(wezterm, window, 'red')
    end

    if b.state_of_charge > 0.75 then
      bat_icon = bat_icons[100]
    elseif b.state_of_charge > 0.5 then
      bat_icon = bat_icons[75]
    elseif b.state_of_charge > 0.25 then
      bat_icon = bat_icons[50]
    else
      bat_icon = bat_icons[25]
    end
  end

  -- Left status (left of the tab line)
  window:set_left_status(wezterm.format {
    { Foreground = { Color = stat_color } },
    { Text = '  ' },
    { Text = stat_icon .. '  ' .. stat },
    { Text = ' | ' },
  })

  -- Right status
  window:set_right_status(wezterm.format {
    -- Wezterm has a built-in nerd fonts
    -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
    { Text = wezterm.nerdfonts.md_account_cowboy_hat .. '  ' .. username },
    { Text = ' | ' },
    { Foreground = { Color = utils.getColorByKey(wezterm, window, 'yellow') } },
    { Text = cwd and wezterm.nerdfonts.md_folder .. '  ' .. cwd or '' },
    'ResetAttributes',
    { Text = cwd and ' | ' or '' },
    { Foreground = { Color = utils.getColorByKey(wezterm, window, 'blue') } },
    -- TODO: figure out how to set icon based on the command
    { Text = cmd and utils.getCommandIcon(wezterm, cmd) .. '  ' .. cmd or '' },
    'ResetAttributes',
    { Text = cmd and ' | ' or '' },
    { Foreground = { Color = bat_color } },
    { Text = has_battery and bat_icon .. '  ' .. bat_percent or '' },
    'ResetAttributes',
    { Text = has_battery and ' | ' or '' },
    { Text = wezterm.nerdfonts.md_clock .. '  ' .. time },
    { Text = '  ' },
  })
end)

-- If tab has zoomed pane, show it in tab
wezterm.on('format-tab-title', function(tab, tabs)
  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '[Z] '
  end

  local index = ''
  if #tabs > 1 then
    index = string.format('%d:', tab.tab_index + 1)
  end

  return ' ' .. zoomed .. index .. ' ' .. tab.active_pane.title .. ' '
end)

--[[ Appearance setting for when I need to take pretty screenshots
config.enable_tab_bar = false
config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.5cell',
  bottom = '0cell',

}
--]]

-- and finally, return the configuration to wezterm
return config

local wezterm = require 'wezterm'
local act = wezterm.action
local features = require 'features'
local globals = require 'utils.globals'
local G = globals.read_globals()

local config = wezterm.config_builder()

-- Fonts
local font = wezterm.font_with_fallback { { family = G.font } }
config.font = font
config.font_size = 14

-- Enable this when you need to debug what it being sent to Wezterm when pressing keys
-- Check the debugger for output
-- config.debug_key_events = true

-- Disable weird behavior for left alt
config.send_composed_key_when_left_alt_is_pressed = true

-- Window
config.window_background_opacity = G.opacity
config.macos_window_background_blur = 50
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'AlwaysPrompt'
config.adjust_window_size_when_changing_font_size = false

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

-- Always for notifications, this is needed for MacOS
config.notification_handling = 'AlwaysShow'

-- Buttery smooth
config.max_fps = 120

-- Keys
config.leader = { key = 'l', mods = 'SUPER', timeout_milliseconds = 1200 }
config.keys = {
  -- Scrolling
  { key = 'PageUp', action = act.ScrollByPage(-0.5) },
  { key = 'PageDown', action = act.ScrollByPage(0.5) },

  -- Send keycode for leader when pressing leader twice
  { key = config.leader.key, mods = 'LEADER|' .. config.leader.mods, action = act.SendKey { key = config.leader.key, mods = config.leader.mods } },
  { key = 'c', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = 's', mods = 'LEADER', action = act.QuickSelect },
  { key = 'phys:Space', mods = 'LEADER', action = act.ActivateCommandPalette },

  -- Switchers
  { key = 'k', mods = 'LEADER', action = features.themes() },
  { key = 'f', mods = 'LEADER', action = features.fonts() },

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
    action = act.ActivateKeyTable { name = 'resize_pane_mode', one_shot = false },
  },

  -- Tab keybindings

  {
    key = 't',
    mods = 'LEADER',
    action = act.ShowTabNavigator,
  },
  {
    key = 'T',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, _, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  -- Key table for moving tabs around
  { key = 'm', mods = 'LEADER', action = act.ActivateKeyTable { name = 'move_tab_mode', one_shot = false } },

  -- Workspace management
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  {
    key = 'W',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for workspace',
      action = wezterm.action_callback(function(_, _, line)
        if line then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    },
  },
  {
    key = 'K',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window)
      local w = window:active_workspace()
      features.kill_workspace(w)
    end),
  },

  -- Disable some default keymaps which I want to use in Neovim
  {
    key = 'Tab',
    mods = 'CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'Tab',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = act.ActivateTab(i - 1),
  })
end

-- Override special alpha characters on Mac Swedish layout to Meta-KEY.
-- Not the prettiest solution, I should probably fix my layout at OS level
-- but I'm too lazy.
for _, v in pairs { 'q', 'w', 'e', 'r', 't', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's', 'd', 'f', 'g', 'z', 'x', 'c', 'v', 'b', 'n', 'm' } do
  table.insert(config.keys, {
    key = v,
    mods = 'META',
    action = act.SendKey { key = v, mods = 'META' },
  })
  table.insert(config.keys, {
    key = v,
    mods = 'META|SHIFT',
    action = act.SendKey { key = v, mods = 'META|SHIFT' },
  })
end

config.native_macos_fullscreen_mode = true

config.key_tables = {
  resize_pane_mode = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
  move_tab_mode = {
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
config.tab_max_width = 100

-- Load plugins
require('plugins/tabline').setup()
require('plugins/smart-splits').setup(config)

-- Recommended settings for tabline
config.show_new_tab_button_in_tab_bar = false
config.colors = {
  tab_bar = {
    background = require('plugins/tabline').tabline.get_theme().normal_mode.c.bg,
  },
}
config.window_padding = {
  left = '0',
  right = '0',
  top = '0',
  bottom = '0',
}

-- and finally, return the configuration to wezterm
return config

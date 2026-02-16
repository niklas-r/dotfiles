---@diagnostic disable-next-line: assign-type-mismatch
local wez = require 'wezterm' ---@type Wezterm

return {
  setup = function(config)
    local smart_splits = wez.plugin.require 'https://github.com/mrjones2014/smart-splits.nvim'
    smart_splits.apply_to_config(config, {
      -- directional keys to use in order of: left, down, up, right
      direction_keys = { 'h', 'j', 'k', 'l' },
      -- modifier keys to combine with direction_keys
      modifiers = {
        move = 'META', -- modifier to use for pane movement, e.g. CTRL+h to move left
        resize = 'META|SHIFT', -- modifier to use for pane resize, e.g. META+h to resize to the left
      },
      -- log level to use: info, warn, error
      log_level = 'info',
    })
  end,
}

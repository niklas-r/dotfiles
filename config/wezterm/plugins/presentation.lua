---@diagnostic disable-next-line: assign-type-mismatch
local wez = require 'wezterm' ---@type Wezterm
local M = {}

M.setup = function(config)
  wez.plugin.require('https://gitlab.com/xarvex/presentation.wez').apply_to_config(config, {
    font_size_multiplier = 1.8, -- sets for both "presentation" and "presentation_full"
    presentation = {
      keybind = { key = 'p', mods = 'LEADER' }, -- setting a keybind
    },
    presentation_full = {
      keybind = { key = 'P', mods = 'LEADER' },
      font_size_multiplier = 2.0, -- overwrites "font_size_multiplier" for "presentation_full"
    },
  })
end

return M

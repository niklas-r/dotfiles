---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require 'wezterm' ---@type Wezterm
local act = wezterm.action

local M = {}

M.pick = function(opts)
  opts.window:perform_action(
    act.InputSelector {
      action = opts.action,
      fuzzy_description = opts.title,
      choices = opts.choices,
      fuzzy = true,
    },
    opts.pane
  )
end

return M

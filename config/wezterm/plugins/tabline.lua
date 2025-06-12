local utils = require 'utils'
local G = require 'globals'

return {
  setup = function(wez)
    local tabline = wez.plugin.require 'https://github.com/michaelbrusegard/tabline.wez'

    tabline.setup {
      options = {
        icons_enabled = true,
        theme = G.colorscheme,
        color_overrides = {},
        section_separators = {
          left = wez.nerdfonts.ple_upper_left_triangle,
          right = wez.nerdfonts.ple_upper_right_triangle,
        },
        component_separators = {
          left = wez.nerdfonts.ple_forwardslash_separator,
          right = wez.nerdfonts.ple_backslash_separator,
        },
        tab_separators = {
          left = wez.nerdfonts.ple_lower_left_triangle,
          right = wez.nerdfonts.ple_lower_right_triangle,
        },
      },
      sections = {
        battery_to_icon = {
          empty = { wez.nerdfonts.fa_battery_empty, color = { fg = utils.getColorByKey(wez, 'red') } },
          quarter = { wez.nerdfonts.fa_battery_quarter, color = { fg = utils.getColorByKey(wez, 'yellow') } },
          half = wez.nerdfonts.fa_battery_half,
          three_quarters = wez.nerdfonts.fa_battery_three_quarters,
          full = wez.nerdfonts.fa_battery_full,
        },
        tabline_a = {
          function(window)
            local mode = 'normal'
            local key_table = window:active_key_table()

            if key_table ~= nil and key_table:find '_mode$' then
              -- strip string '_mode' from end
              mode = key_table:sub(1, -6)
            elseif window:leader_is_active() then
              mode = 'leader'
            end

            return wez.format {
              { Text = ' ' .. mode:upper() .. ' ' },
            }
          end,
        },
        tabline_b = { 'workspace' },
        tabline_c = { ' ' },
        tab_active = {
          'index',
          { 'process', padding = { left = 0, right = 0 }, icons_only = true },
          { 'parent', padding = 0, max_length = 15 },
          '/',
          { 'cwd', padding = { left = 0, right = 1 }, max_length = 20 },
          { 'zoomed', padding = 0 },
        },
        tab_inactive = {
          'index',
          { 'process', padding = { left = 0, right = 0 }, icons_only = true },
          { 'parent', padding = 0, max_length = 5 },
          '/',
          { 'cwd', padding = { left = 0, right = 1 }, max_length = 10 },
        },
        tabline_x = { 'ram', 'cpu' },
        tabline_y = { 'datetime', 'battery' },
        tabline_z = { 'hostname' },
      },
      extensions = {},
    }
  end,
}

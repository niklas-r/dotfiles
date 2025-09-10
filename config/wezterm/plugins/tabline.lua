local utils = require 'utils'
local G = require 'globals'

return {
  setup = function(wez)
    local tabline = wez.plugin.require 'https://github.com/michaelbrusegard/tabline.wez'

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
          {
            'mode',
            fmt = function(output, window)
              if window:leader_is_active() then
                return 'LEADER'
              end
              return output
            end,
          },
        },
        tabline_b = { 'workspace' },
        tabline_c = { ' ' },
        tab_active = getTabComponents(true),
        tab_inactive = getTabComponents(false),
        tabline_x = { 'ram', 'cpu' },
        tabline_y = { 'datetime', 'battery' },
        tabline_z = { 'hostname' },
      },
      extensions = {},
    }
  end,
}

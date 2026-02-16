---@diagnostic disable-next-line: assign-type-mismatch
local wez = require 'wezterm' ---@type Wezterm
local globals = require 'utils.globals'

local G = globals.read_globals()

local M = {}

---@param key "surface" | "foreground" | "background" | "tab_bar_bg" | "black" | "red" | "green" | "yellow" | "blue" | "magenta" | "cyan" | "white" | "black_bright" | "red_bright" | "green_bright" | "yellow_bright" | "blue_bright" | "magenta_bright" | "cyan_bright" | "white_bright"
---@return string
function M.get_color_by_key(key)
  local current_scheme = wez.color.get_builtin_schemes()[G.colorscheme]

  local surface = current_scheme.background or current_scheme.ansi[1]

  if current_scheme.tab_bar and current_scheme.tab_bar.inactive_tab_edge then
    surface = current_scheme.tab_bar.inactive_tab_edge
  end

  local key_to_color = {
    surface = surface,
    foreground = current_scheme.foreground,
    background = current_scheme.background,
    black = current_scheme.ansi[1],
    red = current_scheme.ansi[2],
    green = current_scheme.ansi[3],
    yellow = current_scheme.ansi[4],
    blue = current_scheme.ansi[5],
    magenta = current_scheme.ansi[6],
    cyan = current_scheme.ansi[7],
    white = current_scheme.ansi[8],
    black_bright = current_scheme.brights[1],
    red_bright = current_scheme.brights[2],
    green_bright = current_scheme.brights[3],
    yellow_bright = current_scheme.brights[4],
    blue_bright = current_scheme.brights[5],
    magenta_bright = current_scheme.brights[6],
    cyan_bright = current_scheme.brights[7],
    white_bright = current_scheme.brights[8],
    tab_bar_bg = current_scheme.tab_bar and current_scheme.tab_bar.inactive_tab and current_scheme.tab_bar.inactive_tab.bg_color or current_scheme.background,
  }

  return key_to_color[key]
end

---@type table<string, string> -- key: Neovim theme name, value: Wezterm theme name
local color_scheme_map = {
  -- Tokyo Night Variants
  ['tokyonight-night'] = 'tokyonight_night',
  ['tokyonight-day'] = 'tokyonight_day',
  ['tokyonight-storm'] = 'tokyonight_storm',
  ['tokyonight-moon'] = 'tokyonight_moon',
  -- Catppuccin Variants
  ['catppuccin-frappe'] = 'Catppuccin Frappe',
  ['catppuccin-latte'] = 'Catppuccin Latte',
  ['catppuccin-macchiato'] = 'Catppuccin Macchiato',
  ['catppuccin-mocha'] = 'Catppuccin Mocha',
  -- Rose Pine Variants
  ['rose-pine-main'] = 'rose-pine',
  ['rose-pine-dawn'] = 'rose-pine-dawn',
  ['rose-pine-moon'] = 'rose-pine-moon',
  -- Nightfox Variants
  -- ['nightfox'] = 'nightfox',
  ['dawnfox'] = 'dawnfox',
  -- ['dayfox'] = 'dayfox',
  ['duskfox'] = 'duskfox',
  ['carbonfox'] = 'carbonfox',
  -- ['terafox'] = 'terafox',
  ['nordfox'] = 'nordfox',
}

function M.is_nvim_theme(key)
  for _, wez_name in pairs(color_scheme_map) do
    if key == wez_name then
      return true
    end
  end
  return false
end

---@param color_scheme string
function M.set_nvim_color_scheme(color_scheme)
  local path = globals.nvim_path .. '/colorsaver'
  local nvim_theme = 'catppuccin-frappe' -- default

  for nvim_name, wez_name in pairs(color_scheme_map) do
    if color_scheme == wez_name then
      nvim_theme = nvim_name
    end
  end

  globals.write_to_file(path, nvim_theme)
end

return M

local wez = require 'wezterm'
local globals = require 'utils.globals'

local G = globals.read_globals()

local M = {}

---@param key "surface" | "foreground" | "background" | "tab_bar_bg" | "black" | "red" | "green" | "yellow" | "blue" | "magenta" | "cyan" | "white" | "black_bright" | "red_bright" | "green_bright" | "yellow_bright" | "blue_bright" | "magenta_bright" | "cyan_bright" | "white_bright"
---@return string
function M.get_color_by_key(key)
  local current_scheme = wez.color.get_builtin_schemes()[G.colorscheme]

  local surface = current_scheme.cursor and current_scheme.cursor.bg or current_scheme.ansi[1]

  if string.find(G.colorscheme, 'Catppuccin') then
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

function M.is_nvim_theme(key)
  local nvim_colors = {}

  return nvim_colors[key]
end

---@type table<string[], string> -- key: WezTerm theme name, value: Neovim theme name
local color_scheme_map = {
  -- Tokyo Night Variants
  [{ 'Tokyo Night', 'tokyonight', 'Tokyo Night Light (Gogh)' }] = 'tokyonight',
  [{ 'Tokyo Night Day', 'tokyonight_day', 'tokyonight-day' }] = 'tokyonight-day',
  [{ 'tokyonight_night' }] = 'tokyonight-night',
  [{ 'Tokyo Night Storm', 'Tokyo Night Storm (Gogh)', 'tokyonight-storm', 'TokyoNightStorm (Gogh)' }] = 'tokyonight-storm',
  [{ 'tokyonight_moon', 'Tokyo Night Moon' }] = 'tokyonight-moon',
  -- Catppuccin Variants
  [{ 'Catppuccin Frappe', 'catppuccin-frappe', 'Catppuccin Frappe', 'Catppuccin Frappé (Gogh)' }] = 'catppuccin-frappe',
  [{ 'catppuccin-latte', 'Catppuccin Latte', 'Catppuccin Latte (Gogh)' }] = 'catppuccin-latte',
  [{ 'Catppuccin Macchiato', 'catppuccin-macchiato', 'Catppuccin Macchiato', 'Catppuccin Macchiato (Gogh)' }] = 'catppuccin-macchiato',
  [{ 'Catppuccin Mocha', 'catppuccin-mocha', 'Catppuccin Mocha', 'Catppuccin Mocha (Gogh)' }] = 'catppuccin-mocha',
}

---@param color_scheme string
function M.set_nvim_color_scheme(color_scheme)
  local path = globals.nvim_path .. '/colorsaver'
  local nvim_theme = 'catppuccin-frappe' -- default

  for wez_names, nvim_name in pairs(color_scheme_map) do
    for _, wez_name in ipairs(wez_names) do
      if color_scheme == wez_name then
        nvim_theme = nvim_name
      end
    end
  end

  globals.write_to_file(path, nvim_theme)
end
return M

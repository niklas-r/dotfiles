return {
  { 'catppuccin/nvim', priority = 1000 },
  { 'folke/tokyonight.nvim', priority = 1000 },
  { 'rebelot/kanagawa.nvim', priority = 1000 },
  { 'shatur/neovim-ayu', priority = 1000 },
  {
    'rose-pine/neovim',
    priority = 1000,
    name = 'rose-pine',
    opts = {
      variant = 'auto',
      dark_variant = 'moon',
      styles = {
        transparency = true,
      },
    },
  },
  {
    'propet/colorscheme-persist.nvim',
    lazy = true,
    dependencies = {
      'catppuccin/nvim',
      'folke/tokyonight.nvim',
      'rebelot/kanagawa.nvim',
      'shatur/neovim-ayu',
      'rose-pine/neovim',
    },
    init = function()
      local persist_colorscheme = require 'colorscheme-persist'
      persist_colorscheme.setup()
      local colorscheme = persist_colorscheme.get_colorscheme()
      vim.cmd('colorscheme ' .. colorscheme)
    end,
    keys = {
      {
        '<leader>sc',
        function()
          require('colorscheme-persist').picker()
        end,
        desc = '[S]earch [C]olorscheme',
        { noremap = true, silent = true },
      },
    },
  },
}

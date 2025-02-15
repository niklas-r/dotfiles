return {
  'propet/colorscheme-persist.nvim',
  lazy = true,
  dependencies = {
    'nvim-telescope/telescope-dap.nvim',
    'catppuccin/nvim',
    'folke/tokyonight.nvim',
    'rebelot/kanagawa.nvim',
    'shatur/neovim-ayu',
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
}

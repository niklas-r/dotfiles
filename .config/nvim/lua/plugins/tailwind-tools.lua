return {
  'luckasRanarison/tailwind-tools.nvim',
  name = 'tailwind-tools',
  build = ':UpdateRemotePlugins',
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'neovim/nvim-lspconfig', -- optional
  },
  opts = {}, -- your configuration
}

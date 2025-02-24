return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
  opts = {},
}

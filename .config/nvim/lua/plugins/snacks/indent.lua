return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  depenencies = {
    'folke/which-key.nvim',
  },
  opts = {
    indent = {
      enabled = true,
      animate = {
        enabled = false,
      },
      scope = {
        enabled = true,
      },
    },
  },
}

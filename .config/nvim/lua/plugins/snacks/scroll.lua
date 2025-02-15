return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  depenencies = {
    'folke/which-key.nvim',
  },
  opts = {
    scroll = {
      animate = {
        duration = {
          steps = 10,
          total = 120,
        },
        easing = 'inQuad',
      },
    },
  },
}

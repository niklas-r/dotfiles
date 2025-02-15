return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
    default_file_explorer = true,
  },
  -- Optional dependencies
  dependencies = {
    {
      'echasnovski/mini.icons',
      opts = {},
    },
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' } },
  },
}

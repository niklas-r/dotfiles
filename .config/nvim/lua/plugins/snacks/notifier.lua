return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  keys = {
    {
      '<leader>n',
      function()
        Snacks.notifier.show_history()
      end,
      desc = '[N]otification History',
    },
  },
  opts = {
    notifier = { enabled = true },
  },
}

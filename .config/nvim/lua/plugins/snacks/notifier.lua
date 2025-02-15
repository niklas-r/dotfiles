return {
  'folke/snacks.nvim',
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

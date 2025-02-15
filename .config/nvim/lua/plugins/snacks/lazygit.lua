return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  keys = {
    {
      '<leader>lh',
      function()
        Snacks.lazygit.log_file()
      end,
      desc = '[L]azygit Current File [H]istory',
    },
    {
      '<leader>lg',
      function()
        Snacks.lazygit()
      end,
      desc = '[L]azy[g]it',
    },
    {
      '<leader>ll',
      function()
        Snacks.lazygit.log()
      end,
      desc = '[L]azygit [L]og (cwd)',
    },
  },
  opts = {
    lazygit = { enabled = true },
  },
}

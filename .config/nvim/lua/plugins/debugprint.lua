return {
  'andrewferrier/debugprint.nvim',
  lazy = false, -- Required to make line highlighting work before debugprint is first used
  version = '*', -- Remove if you DON'T want to use the stable version
  dependencies = {
    'echasnovski/mini.nvim', -- Optional: Needed for line highlighting (full mini.nvim plugin)
    'folke/snacks.nvim', -- Optional: If you want to use the `:Debugprint search` command with snacks.nvim
    'folke/which-key.nvim',
  },
  opts = {},
  init = function()
    local wk = require 'which-key'
    wk.add { lhs = 'g?', group = 'Debug print' }

    vim.keymap.set('n', 'g?r', '<CMD>:ResetDebugPrintsCounter<CR>', { desc = 'Reset counter' })
    vim.keymap.set('n', 'g?q', '<CMD>:DebugPrintQFList<CR>', { desc = 'Debug print quickfix list' })
    vim.keymap.set('n', 'g?d', '<CMD>:DeleteDebugPrints<CR><CMD>:ResetDebugPrintsCounter<CR>', { desc = 'Delete debug prints' })
    vim.keymap.set('n', 'g?c', '<CMD>:ToggleCommentDebugPrints<CR>', { desc = 'Toggle comment debug prints' })
  end,
}

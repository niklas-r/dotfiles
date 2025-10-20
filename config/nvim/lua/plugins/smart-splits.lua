-- This enables us to lazy load smart splits
vim.g.smart_splits_multiplexer_integration = 'wezterm'

return {
  'mrjones2014/smart-splits.nvim',
  dependencies = {
    'folke/which-key.nvim',
  },
  event = 'VeryLazy',
  opts = {
    ignored_buftypes = {
      'nofile',
      'quickfix',
      'prompt',
    },
    -- Ignored filetypes (only while resizing)
    ignored_filetypes = {
      'NvimTree',
    },
    -- the default number of lines/columns to resize by at a time
    default_amount = 3,
  },
  config = function(_, opts)
    local ss = require 'smart-splits'
    ss.setup(opts)

    -- recommended mappings
    -- resizing splits
    -- these keymaps will also accept a range,
    -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
    vim.keymap.set('n', '<M-S-h>', ss.resize_left, { desc = 'Resize split leftward' })
    vim.keymap.set('n', '<M-S-j>', ss.resize_down, { desc = 'Resize split downward' })
    vim.keymap.set('n', '<M-S-k>', ss.resize_up, { desc = 'Resize split upward' })
    vim.keymap.set('n', '<M-S-l>', ss.resize_right, { desc = 'Resize split rightward' })
    -- moving between splits
    vim.keymap.set('n', '<M-h>', ss.move_cursor_left, { desc = 'Move cursor to left split' })
    vim.keymap.set('n', '<M-j>', ss.move_cursor_down, { desc = 'Move cursor to split below' })
    vim.keymap.set('n', '<M-k>', ss.move_cursor_up, { desc = 'Move cursor to split above' })
    vim.keymap.set('n', '<M-l>', ss.move_cursor_right, { desc = 'Move cursor to right split' })
    -- swapping buffers between windows
    vim.keymap.set('n', '<leader>wbh', ss.swap_buf_left, { desc = '' })
    vim.keymap.set('n', '<leader>wbj', ss.swap_buf_down, { desc = '' })
    vim.keymap.set('n', '<leader>wbk', ss.swap_buf_up, { desc = '' })
    vim.keymap.set('n', '<leader>wbl', ss.swap_buf_right, { desc = '' })
  end,
}

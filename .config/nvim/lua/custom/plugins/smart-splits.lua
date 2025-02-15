return {
  'mrjones2014/smart-splits.nvim',
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
  keys = {
    -- recommended mappings
    -- resizing splits
    -- these keymaps will also accept a range,
    -- for example `10<M-C-h>` will `resize_left` by `(10 * config.default_amount)`
    {
      '<M-Left>',
      function()
        require('smart-splits').resize_left()
      end,
      desc = 'Resize left',
    },
    {
      '<M-Down>',
      function()
        require('smart-splits').resize_down()
      end,
      desc = 'Resize down',
    },
    {
      '<M-Up>',
      function()
        require('smart-splits').resize_up()
      end,
      desc = 'Resize up',
    },
    {
      '<M-Right>',
      function()
        require('smart-splits').resize_right()
      end,
      desc = 'Resize right',
    },
    -- moving between splits
    {
      '<C-h>',
      function()
        require('smart-splits').move_cursor_left()
      end,
      desc = 'Move cursor left',
    },
    {
      '<C-j>',
      function()
        require('smart-splits').move_cursor_down()
      end,
      desc = 'Move cursor down',
    },
    {
      '<C-k>',
      function()
        require('smart-splits').move_cursor_up()
      end,
      desc = 'Move cursor up',
    },
    {
      '<C-l>',
      function()
        require('smart-splits').move_cursor_right()
      end,
      desc = 'Move cursor right',
    },
    -- swapping buffers between windows
    {
      '<leader>bh',
      function()
        require('smart-splits').swap_buf_left()
      end,
      desc = 'Swap [B]uffer left',
    },
    {
      '<leader>bj',
      function()
        require('smart-splits').swap_buf_down()
      end,
      desc = 'Swap [B]uffer down',
    },
    {
      '<leader>bk',
      function()
        require('smart-splits').swap_buf_up()
      end,
      desc = 'Swap [B]uffer up',
    },
    {
      '<leader>bl',
      function()
        require('smart-splits').swap_buf_right()
      end,
      desc = 'Swap [B]uffer right',
    },
  },
}

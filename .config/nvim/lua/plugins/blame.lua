return {
  {
    'FabijanZulj/blame.nvim',
    event = 'BufRead',
    config = function(_, opts)
      require('blame').setup {}

      vim.api.nvim_create_autocmd('User', {
        pattern = 'BlameViewOpened',
        callback = function(event)
          local wk = require 'which-key'
          local map = function(key, desc)
            wk.add { key, desc = desc, buffer = event.buf, nowait = true, silent = true, noremap = true }
          end
          -- event.buf
          map('i', 'Blame: Commit info')
          map('<TAB>', 'Blame: Stack push')
          map('<BS>', 'Blame: Stack pop')
          map('<CR>', 'Blame: Show commit')
          map('<ESC>', 'Blame: close')
          map('q', 'Blame: close')
        end,
      })
    end,
  },
}

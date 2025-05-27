return {
  'vuki656/package-info.nvim',
  dependencies = { 'MunifTanjim/nui.nvim', 'folke/which-key.nvim' },
  lazy = true,
  event = 'BufRead package.json',
  config = function()
    local pi = require 'package-info'
    pi.setup {
      autostart = false,
      hide_up_to_date = true,
    }

    local wk = require 'which-key'
    wk.add { '<leader>p', group = '[P]ackage.json' }

    local map = function(map, cmd, desc)
      vim.keymap.set('n', map, cmd, { silent = true, noremap = true, desc = desc, buffer = 0 })
    end

    map('<leader>pt', pi.toggle, '[T]oggle dependency version')
    map('<leader>pu', pi.update, '[U]pdate dependency on the line')
    map('<leader>pd', pi.delete, '[D]elete dependency on the line')
    map('<leader>pi', pi.install, '[I]nstall a new dependency')
    map('<leader>pc', pi.change_version, '[C]hange dependency version')
  end,
}

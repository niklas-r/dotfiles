local deno = require 'plugins.snacks.utils.deno'

local ts_exec = {
  keys = {
    ['<cr>'] = {
      function(self)
        deno.run(self.buf)
      end,
      desc = 'Run TypeScript Scratch',
      mode = { 'n', 'x' },
    },
  },
}

return {
  'folke/snacks.nvim',
  opts = {
    scratch = {
      win_by_ft = {
        typescript = ts_exec,
        typescriptreact = ts_exec,
        javascript = ts_exec,
        javascriptreact = ts_exec,
      },
    },
  },
  keys = {
    {
      '<leader>.',
      function()
        Snacks.scratch()
      end,
      desc = 'Toggle Scratch Buffer',
    },
    {
      '<leader>S',
      function()
        Snacks.picker.scratch()
      end,
      desc = 'Select Scratch Buffer',
    },
  },
}

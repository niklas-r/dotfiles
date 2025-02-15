return {
  'nvim-neotest/neotest',
  event = 'VeryLazy',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    -- Vitest
    'marilari88/neotest-vitest',
  },
  config = function(opts)
    require('neotest').setup {
      adapters = {
        require 'neotest-vitest',
      },
      quickfix = { open = true },
      output = {
        enabled = true,
        open = 'botright split | resize 15',
      },
    }
  end,
  keys = {
    {
      '<leader>us',
      function()
        require('neotest').summary.toggle()
      end,
      desc = '[U]nit Test [S]ummary',
    },
    {
      '<leader>uo',
      function()
        require('neotest').output()
      end,
      desc = '[U]nit Test [O]utput',
    },
    {
      '<leader>up',
      function()
        require('neotest').output_panel()
      end,
      desc = '[U]nit Test Output [P]anel',
    },
    {
      '<leader>urt',
      function()
        require('neotest').run.run()
      end,
      desc = '[U]nit Test [R]un Nearest [T]est',
    },
    {
      '<leader>urf',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = '[U]nit Test [R]un Current [F]ile',
    },
    -- {
    --   '<leader>ud',
    --   function()
    --     require('neotest').run.run { strategy = 'dap' }
    --   end,
    --   desc = '[U]nit Test [D]ebug Nearest Test',
    -- },
    {
      '<leader>ua',
      function()
        require('neotest').run.attach()
      end,
      desc = '[U]nit Test [A]ttach Nearest Test',
    },
    {
      ']t',
      function()
        require('neotest').jump.next()
      end,
      desc = 'Next test',
    },

    {
      '[t',
      function()
        require('neotest').jump.prev()
      end,
      desc = 'Prev test',
    },
    {
      ']T',
      function()
        require('neotest').jump.next { status = 'failed' }
      end,
      desc = 'Next failed test',
    },

    {
      '[T',
      function()
        require('neotest').jump.prev { status = 'failed' }
      end,
      desc = 'Prev failed test',
    },
  },
}

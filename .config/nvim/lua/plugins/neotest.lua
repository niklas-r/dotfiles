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
        require 'neotest-vitest' {
          vitestCommand = 'yarn vitest run --coverage.enabled=false',
        },
      },
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
    {
      '<leader>url',
      function()
        require('neotest').run.run_last()
      end,
      desc = '[U]nit Test [R]un: [L]ast Test',
    },
    {
      '<leader>udt',
      function()
        require('neotest').run.run { strategy = 'dap' }
      end,
      desc = '[U]nit Test [D]ebug: Nearest [T]est',
    },
    {
      '<leader>udl',
      function()
        require('neotest').run.run_last { strategy = 'dap' }
      end,
      desc = '[U]nit Test [D]ebug: [L]ast Test',
    },
    {
      '<leader>ua',
      function()
        require('neotest').run.attach()
      end,
      desc = '[U]nit Test [A]ttach Nearest Test',
    },
  },
}

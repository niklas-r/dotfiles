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
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-vitest' {
          vitestCommand = 'npx vitest run --coverage.enabled=true --coverage.reporter=lcov --reporter=dot',
          cwd = function(testFilePath)
            return vim.fs.root(testFilePath, 'node_modules')
          end,
          filter_dir = function(name)
            return name ~= 'e2e' and name ~= 'node_modules'
          end,
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
      desc = '[S]ummary',
    },
    {
      '<leader>uo',
      function()
        require('neotest').output()
      end,
      desc = '[O]utput',
    },
    {
      '<leader>up',
      function()
        require('neotest').output_panel()
      end,
      desc = 'Output [P]anel',
    },
    {
      '<leader>urt',
      function()
        require('neotest').run.run()
      end,
      desc = '[R]un Nearest [T]est',
    },
    {
      '<leader>urf',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = '[R]un Current [F]ile',
    },
    {
      '<leader>url',
      function()
        require('neotest').run.run_last()
      end,
      desc = '[R]un: [L]ast Test',
    },
    {
      '<leader>udt',
      function()
        require('neotest').run.run { strategy = 'dap' }
      end,
      desc = '[D]ebug: Nearest [T]est',
    },
    {
      '<leader>udl',
      function()
        require('neotest').run.run_last { strategy = 'dap' }
      end,
      desc = '[D]ebug: [L]ast Test',
    },
    {
      '<leader>ua',
      function()
        require('neotest').run.attach()
      end,
      desc = '[A]ttach Nearest Test',
    },
  },
}

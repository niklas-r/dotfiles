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
    -- Jest
    'nvim-neotest/neotest-jest',
  },
  config = function()
    local function is_cra_package(file)
      local root = vim.fs.root(file, 'node_modules')
      return root ~= nil and vim.uv.fs_stat(root .. '/node_modules/.bin/react-app-rewired') ~= nil
    end

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
        -- Keep after vitest: neotest-vitest only claims files in projects that
        -- depend on vitest, so jest projects fall through to this adapter.
        require 'neotest-jest' {
          jestCommand = function(file)
            return is_cra_package(file) and 'npx react-app-rewired test --watchAll=false' or 'npx jest'
          end,
          jestConfigFile = function(file)
            -- CRA's test script generates its own config and passes it via --config.
            if is_cra_package(file) then
              return nil
            end
            local root = vim.fs.root(file, 'node_modules') or vim.fn.getcwd()
            for _, name in ipairs { 'jest.config.ts', 'jest.config.js', 'jest.config.mjs', 'jest.config.cjs' } do
              local candidate = root .. '/' .. name
              if vim.fn.filereadable(candidate) == 1 then
                return candidate
              end
            end
            return nil
          end,
          -- A nil config becomes a relative 'jest.config.js' that neotest-jest checks
          -- against Neovim's cwd, not the test's, so it can pass the wrong package's
          -- config. Drop it and let the test command find its own.
          jestArguments = function(args, context)
            if context.config ~= 'jest.config.js' then
              return args
            end
            return vim.tbl_filter(function(arg)
              return not vim.startswith(arg, '--config=')
            end, args)
          end,
          cwd = function(testFilePath)
            return vim.fs.root(testFilePath, 'node_modules')
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
        require('neotest').output.open { enter = true }
      end,
      desc = '[O]utput',
    },
    {
      '<leader>up',
      function()
        require('neotest').output_panel.toggle()
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

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'mxsdev/nvim-dap-vscode-js',
    },
    lazy = true,
    keys = function(_, keys)
      local dap = require 'dap'
      return {
        { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
        { '<F1>', dap.step_into, desc = 'Debug: Step Into' },
        { '<F2>', dap.step_over, desc = 'Debug: Step Over' },
        { '<F3>', dap.step_out, desc = 'Debug: Step Out' },
        unpack(keys),
      }
    end,
    config = function()
      -- local dap = require 'dap'

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          'chrome-debug-adapter',
          'js-debug-adapter',
        },
      }

      -- Change breakpoint icons
      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
      local breakpoint_icons = vim.g.have_nerd_font
          and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
        or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
      for type, icon in pairs(breakpoint_icons) do
        local tp = 'Dap' .. type
        local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end
    end,
  },
  {
    'miroshQa/debugmaster.nvim',
    -- osv is needed if you want to debug neovim lua code. Also can be used
    -- as a way to quickly test-drive the plugin without configuring debug adapters
    dependencies = { 'mfussenegger/nvim-dap', 'jbyuki/one-small-step-for-vimkind' },
    lazy = true,
    keys = function(_, keys)
      local dm = require 'debugmaster'
      return {
        { '<leader>D', dm.mode.toggle, { desc = 'Debug mode', mode = { 'n', 'v' }, nowait = true } },
        unpack(keys),
      }
    end,
    config = function()
      local dm = require 'debugmaster'
      -- make sure you don't have any other keymaps that starts with "<leader>d" to avoid delay
      -- Alternative keybindings to "<leader>d" could be: "<leader>m", "<leader>;"
      vim.keymap.set({ 'n', 'v' }, '<leader>D', dm.mode.toggle, { nowait = true })
      -- If you want to disable debug mode in addition to leader+D using the Escape key:
      -- vim.keymap.set("n", "<Esc>", dm.mode.disable)
      -- This might be unwanted if you already use Esc for ":noh"
      vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

      dm.plugins.osv_integration.enabled = true -- needed if you want to debug neovim lua code
      -- local dap = require 'dap'
      -- Configure your debug adapters here
      -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
    end,
  },
}

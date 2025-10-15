return {
  {
    'stevearc/quicker.nvim',
    ft = 'qf',
    keys = {
      {
        '<leader>Q',
        function()
          require('quicker').toggle()
        end,
        desc = 'Toggle [Q]uickfix',
      },
      {
        '<leader>L',
        function()
          require('quicker').toggle { loclist = true }
        end,
        desc = 'Toggle [L]oclist',
      },
    },
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      keys = {
        {
          '>',
          function()
            require('quicker').expand { before = 2, after = 2, add_to_existing = true }
          end,
          desc = 'Expand quickfix context',
        },
        {
          '<',
          function()
            require('quicker').collapse()
          end,
          desc = 'Collapse quickfix context',
        },
      },
    },
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
}

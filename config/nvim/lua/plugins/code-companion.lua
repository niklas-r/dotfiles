local snacks_provider = {
  provider = 'snacks', -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
}

local anthropic_adapter = {
  adapter = 'anthropic',
}

return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- Picker
      'folke/snacks.nvim',
      -- Nicer diffs
      'echasnovski/mini.diff',
      -- Dependepcies used by extensions
      'ravitemer/mcphub.nvim',
    },
    cmd = {
      'CodeCompanion',
      'CodeCompanionActions',
      'CodeCompanionChat',
      'CodeCompanionCmd',
    },
    opts = {
      display = {
        action_palette = {
          provider = 'default',
        },
      },

      strategies = {
        chat = vim.tbl_extend('force', anthropic_adapter, {
          slash_commands = {
            ['buffer'] = {
              opts = snacks_provider,
            },
            ['file'] = {
              opts = snacks_provider,
            },
            ['symbols'] = {
              opts = snacks_provider,
            },
            ['fetch'] = {
              opts = snacks_provider,
            },
          },
        }),
        inline = anthropic_adapter,
        cmd = anthropic_adapter,
      },
      extensions = {
        mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
      },
    },
    init = function()
      vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>', { desc = '[A]ctions', noremap = true, silent = true })
      vim.keymap.set({ 'n', 'v' }, '<leader>at', '<cmd>CodeCompanionChat Toggle<cr>', { desc = '[T]oggle chat', noremap = true, silent = true })
      vim.keymap.set('v', '<leader>ac', '<cmd>CodeCompanionChat Add<cr>', { desc = 'Add selection to [C]hat', noremap = true, silent = true })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd [[cab cc CodeCompanion]]
    end,
    config = function(_, opts)
      require('codecompanion').setup(opts)
      require('plugins.code-companion.utils.extmarks').setup()
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      file_types = { 'markdown', 'codecompanion' },
    },
    ft = { 'markdown', 'codecompanion' },
  },
  -- Use mini.diff for cleaner diff when using the inline assistant or the `@insert_edit_into_file` tool
  {
    'echasnovski/mini.diff',
    config = function()
      local diff = require 'mini.diff'
      diff.setup {
        -- Disabled by default
        source = diff.gen_source.none(),
      }
    end,
  },
}

local snacks_provider = {
  provider = 'snacks', -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
}

local anthropic_adapter = {
  adapter = {
    name = 'anthropic',
    model = 'claude-sonnet-4-5-20250929',
  },
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
      'nvim-mini/mini.diff',
      -- Dependencies used by extensions
      'ravitemer/mcphub.nvim',
      -- Chat history extension
      'ravitemer/codecompanion-history.nvim',
      -- Nice markdown
      'MeanderingProgrammer/render-markdown.nvim',
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
            ['help'] = {
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
            -- MCP Tools
            make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
            show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
            add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
            show_result_in_chat = true, -- Show tool results directly in chat buffer
            -- MCP Resources
            make_vars = true, -- Convert MCP resources to #variables for prompts
            -- MCP Prompts
            make_slash_commands = true, -- Add MCP prompts as /slash commands
          },
        },
        history = {
          enabled = true,
          opts = {
            -- Number of days after which chats are automatically deleted (0 to disable)
            expiration_days = 30,
            -- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
            picker = 'snacks',
            title_generation_opts = {
              -- We set copilot as the adapter because ACP adapters does not support title generation currently
              adapter = 'copilot', -- "copilot"
              model = 'gpt-4o', -- "gpt-4o"
            },
          },
        },
      },
      prompt_library = {
        markdown = {
          dirs = {
            vim.fn.getcwd() .. '/.prompts',
            os.getenv 'DOTFILES_DIR' .. '/config/nvim/lua/plugins/code-companion/prompts',
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
    'ravitemer/mcphub.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required for Job and HTTP requests
    },
    -- comment the following line to ensure hub will be ready at the earliest
    cmd = 'MCPHub', -- lazy load by default
    -- build = 'npm install -g mcp-hub@latest', -- Installs required mcp-hub npm module
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    build = 'bundled_build.lua', -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    ---@type MCPHub.Config
    opts = {
      use_bundled_binary = true,
      auto_approve = true,
    },
  },
  -- Use mini.diff for cleaner diff when using the inline assistant or the `@insert_edit_into_file` tool
  {
    'nvim-mini/mini.diff',
    config = function()
      local diff = require 'mini.diff'
      diff.setup {
        -- Disabled by default
        source = diff.gen_source.none(),
      }
    end,
  },
}

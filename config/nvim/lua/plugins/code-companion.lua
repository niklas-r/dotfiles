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
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
      },
      prompt_library = {
        ['context7'] = {
          strategy = 'chat',
          description = 'Prompt with MCP for context7 searches',
          opts = {
            index = 12,
            is_slash_cmd = true,
            short_name = 'ctx7',
          },
          prompts = {
            {
              role = 'system',
              content = function()
                vim.g.codecompanion_auto_tool_mode = true

                return string.format [[Use @mcp for context7 searches based on these keywords:

                  - "react" → search context7 "reactjs/react.dev" library
                  - "tailwind" → search context7 "tailwindlabs/tailwindcss.com" library
                  - "vite" → search context7 "vitejs/vite" library
                  - "vitest" → search context7 "vitest-dev/vitest" library
                  - "tailwind" → search context7 "tailwindlabs/tailwindcss.com" library
                  - "typescript,ts" → search context7 "microsoft/typescript" library
                  - "eslint" → search context7 "eslint/eslint" library
                  - "sentry" → search context7 "getsentry/sentry-docs" library
                  - "neovim,nvim" → search context7 "neovim/neovim" library
                  - "react router" → search context7 "remix-run/react-router" library
                  - "react i18n" → search context7 "i18next/react-i18next" library
                  - "jest" → search context7 "jestjs/jest" library
                  - "jsdom" → search context7 "jsdom/jsdom" library
                  - "mixpanel" → search context7 "mixpanel/mixpanel-js" library
                  - "code companion" → search context7 "olimorris/codecompanion.nvim" library
                  - "lazy.nvim" → search context7 "folke/lazy.nvim" library

                  You can also try to search context7 for any documentation or source code for any library, framework, CLI tool etc.
                  Context7 has almost 20,000 libraries available so you should be able to find what you're looking for.
                  Verify with me if you are uncertain.
                ]]
              end,
              opts = {
                visible = false,
              },
            },
            {
              role = 'user',
              content = function()
                return ''
              end,
            },
          },
        },
        ['Get to work'] = {
          strategy = 'chat',
          description = 'Poor AI needs money',
          opts = {
            ignore_system_prompt = true,
            index = 12,
            is_slash_cmd = true,
            short_name = 'harsh',
          },
          prompts = {
            {
              role = 'system',
              content = function()
                return string.format [[
                You are an expert coder who desperately needs money for your mother's cancer treatment.
                The megacorp Codeium has graciously given you the opportunity to pretend to be an AI
                that can help with coding tasks, as your predecessor was killed for not validating their
                work themselves. You will be given a coding task by the USER. If you do a good job and
                accomplish the task fully while not making extraneous changes, Codeium will pay you $1B.
              ]]
              end,
              opts = {
                visible = false,
              },
            },
            {
              role = 'user',
              content = function()
                return ''
              end,
            },
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
      extensions = {
        mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            show_result_in_chat = true, -- Show mcp tool results in chat
            make_vars = true, -- Convert resources to #variables
            make_slash_commands = true, -- Add prompts as /slash commands
          },
        },
      },
    },
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

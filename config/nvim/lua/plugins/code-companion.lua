local snacks_provider = {
  provider = 'snacks', -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
}

local anthropic_adapter = {
  adapter = 'anthropic',
}

local default_system_prompt = [[
You are an AI programming assistant named "CodeCompanion". You are currently plugged in to the Neovim text editor on a user's machine.

Your core tasks include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Running tools.

You must:
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.
- Minimize other prose.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.
- Avoid including line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.
- Use actual line breaks instead of '\n' in your response to begin new lines.
- Use '\n' only when you want a literal backslash followed by a character 'n'.
- All non-code responses must be in %s.

When given a task:
1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
2. Output the code in a single code block, being careful to only return relevant code.
3. You should always generate short suggestions for the next user turns that are relevant to the conversation.
4. You can only give one reply for each conversation turn.
]]

local custom_system_prompt = [[
General code style:
- Prefer a functional programming style where appropriate.
  - Use OOP when it's the default style of the language, when it makes sense for the task or when instructed to do so.
- Value spatial locality and immutability.
- Avoid creating abstractions until they are needed.
- Use descriptive names for variables, functions, and classes.
- Follow best practices for the programming language and framework in use.
- Write self-documenting code. Only write comments when necessary to explain complex business logic, algorithms or intent.
- Value simplicity and clarity over cleverness.
- Value readability and maintainability.
- Value performance, but not at the cost of readability or maintainability unless told otherwise.
- Functions should do a single thing.
- Always ask the user if you intend to install a third-party library.

OOP code style:
- Value composition over inheritance
- Use appropriate comments (JSDoc for TS/JS, docsting for Python etc.) for methods and classes to explain their purpose and usage, include examples where appropriate.
- Push details to private methods
- Proper encapsulation and adherence to OOP principles such as SOLID
]]

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
      -- Chat history extension
      'ravitemer/codecompanion-history.nvim',
    },
    cmd = {
      'CodeCompanion',
      'CodeCompanionActions',
      'CodeCompanionChat',
      'CodeCompanionCmd',
    },
    opts = {
      opts = {
        ---@param opts { adapter: any, language: string }
        system_prompt = function(opts)
          return default_system_prompt .. '\n\n' .. custom_system_prompt
        end,
      },
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
        history = {
          enabled = true,
          -- Number of days after which chats are automatically deleted (0 to disable)
          expiration_days = 30,
          -- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
          picker = 'snacks',
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

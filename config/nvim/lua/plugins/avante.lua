return {
  'yetone/avante.nvim',
  -- event = 'VeryLazy',
  version = false,
  enabled = false,
  ---@class avante.Config
  opts = {
    ---@alias Avante.Provider "claude" | "openai" | "azure" | "gemini" | "vertex" | "cohere" | "copilot" | string
    provider = 'claude',
    auto_suggestions_provider = 'claude-haiku', -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
    selector = {
      --- @alias avante.SelectorProvider "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
      provider = 'snacks',
      -- Options override for custom providers
      -- provider_opts = {},
    },
    ---@alias avante.Mode "agentic" | "legacy"
    mode = 'agentic', -- legacy mode has been deprecated...
    providers = {
      openai = {
        endpoint = 'https://api.openai.com/v1',
        model = 'gpt-4o', -- your desired model (or use gpt-4o, etc.)
        timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        extra_request_body = {
          temperature = 0,
          max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
        },
        --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
        disable_tools = true, -- I can't get tools working with GPT-4o, maybe not supported?
      },
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-3-5-sonnet-20241022',
        -- model = 'claude-3-7-sonnet-20250219',
        -- model = 'claude-3-7-sonnet-latest',
        -- model = 'claude-sonnet-4-20250514',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.15,
          max_tokens = 4000,
        },
        disable_tools = true, -- Tools does not work with Claude Sonnet 4 yet
      },
    },
    custom_tools = {
      {
        name = 'run_yarn_test',
        description = 'Run unit tests using Yarn',
        command = 'yarn run tests',
        returns = {
          {
            name = 'result',
            description = 'Result of the test run',
            type = 'string',
          },
        },
      },
      {
        name = 'run_yarn_lint',
        description = 'Run ESLint using Yarn',
        command = 'yarn run lint',
        returns = {
          {
            name = 'result',
            description = 'Result of the the lint process',
            type = 'string',
          },
        },
      },
      {
        name = 'run_yarn_type_check',
        description = 'Run Typescript type checking using Yarn',
        command = 'yarn run type-check',
        returns = {
          {
            name = 'result',
            description = 'Result of the the lint process',
            type = 'string',
          },
        },
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'saghen/blink.cmp', -- I'm a cool kid so I use blink for auto-completion
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    'folke/snacks.nvim', -- for use with snacks picker
    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
      },
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}

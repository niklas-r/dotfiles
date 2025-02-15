return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = '*', -- only get "stable" versions

  -- Avante >0.0.14 doesn't allow "copilot" as a provider anymore.
  -- If you want to use copilot you need to downgrade to 0.0.14 for now.
  --
  -- Follow discussions:
  -- https://github.com/yetone/avante.nvim/pull/1072
  -- version = '0.0.14',
  ---@class avante.Config
  opts = {
    ---@alias Avante.Provider "claude" | "openai" | "azure" | "gemini" | "vertex" | "cohere" | "copilot" | string
    provider = 'claude', -- Recommend using Claude
    auto_suggestions_provider = 'claude-haiku', -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
    -- This is a setup to use sonnet with copilot provider, possible with <= 0.0.14
    -- auto_suggestions_provider = 'copilot', -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
    -- copilot = {
    --   endpoint = 'https://api.githubcopilot.com/',
    --   model = 'claude-3.5-sonnet',
    --   proxy = nil, -- [protocol://]host[:port] Use this proxy
    --   allow_insecure = false, -- Do not allow insecure server connections
    --   timeout = 30000, -- Timeout in milliseconds
    --   temperature = 0.1, -- kinda creative
    --   max_tokens = 8192,
    -- },

    file_selector = {
      --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string
      provider = 'snacks',
      -- Options override for custom providers, currently only works with fzf and telescope
      -- provider_opts = {},
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
    -- 'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'saghen/blink.cmp', -- I'm a cool kid so I use blink for auto-completion
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    'folke/snacks.nvim', -- for use with snacks picker
    -- I don't really want image pasting right now
    -- {
    --   -- support for image pasting
    --   "HakonHarnes/img-clip.nvim",
    --   event = "VeryLazy",
    --   opts = {
    --     -- recommended settings
    --     default = {
    --       embed_image_as_base64 = false,
    --       prompt_for_file_name = false,
    --       drag_and_drop = {
    --         insert_mode = true,
    --       },
    --       -- required for Windows users
    --       use_absolute_path = true,
    --     },
    --   },
    -- },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}

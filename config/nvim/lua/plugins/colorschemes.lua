return {
  {
    'catppuccin/nvim',
    dependencies = {
      'nvim-lualine/lualine.nvim',
    },
    name = 'catppuccin',
    -- enabled = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { 'italic' }, -- Change the style of comments
          conditionals = {},
          loops = {},
          functions = { 'italic' },
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = { 'italic' },
          properties = {},
          types = {},
          operators = {},
          -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        integrations = {
          -- Avante moves fast and this integration is broken
          -- avante = true,
          blink_cmp = true,
          dap_ui = true,
          dropbar = true,
          gitsigns = true,
          harpoon = true,
          lsp_trouble = true,
          mason = true,
          neotest = true,
          neotree = true,
          noice = true,
          snacks = {
            enabled = true,
            indent_scope_color = 'lavender',
          },
          treesitter = true,
          which_key = true,
        },
      }
      -- Hack but atleast the config is in one place
      vim.schedule(function()
        vim.cmd ":lua require'lualine'.setup { options = { theme = 'catppuccin' } }"
      end)
    end,
  },
  {
    'folke/tokyonight.nvim',
    enabled = true,
    priority = 1000,
    opts = {
      style = 'moon',
      transparent = false,
      dim_inactive = true,
      styles = {
        comments = { italic = true },
        functions = { italic = true },
        booleans = { italic = true },
      },
    },
  },
  {
    'rose-pine/neovim',
    enabled = false,
    priority = 1000,
    name = 'rose-pine',
    opts = {
      variant = 'auto',
      dark_variant = 'moon',
      styles = {
        -- transparency = true,
      },
    },
  },
  -- colorsaver automatically save/loads the last used color scheme
  {
    'https://git.sr.ht/~swaits/colorsaver.nvim',
    lazy = true,
    event = 'VimEnter',
    opts = {},
  },
}

return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
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
        blink_cmp = true,
        dap_ui = true,
        diffview = true,
        dropbar = true,
        gitsigns = true,
        harpoon = true,
        lsp_trouble = true,
        mason = true,
        neotest = true,
        neotree = true,
        noice = true,
        octo = true,
        snacks = {
          enabled = true,
          indent_scope_color = 'lavender',
        },
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    'folke/tokyonight.nvim',
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
  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    opts = {
      options = {
        styles = { -- Style to be applied to different syntax groups
          comments = 'italic', -- Value is any valid attr-list value `:help attr-list`
          conditionals = 'NONE',
          constants = 'NONE',
          functions = 'italic',
          keywords = 'NONE',
          numbers = 'NONE',
          operators = 'NONE',
          strings = 'NONE',
          types = 'NONE',
          variables = 'NONE',
        },
        modules = {
          gitsigns = true,
          diagnostic = {
            enable = true,
          },
          native_lsp = {
            enable = true,
          },
          ['lazy.nvim'] = true,
          neotest = true,
          neotree = true,
          treesitter = true,
          whichkey = true,
        },
      },
      groups = {
        all = {
          ['@boolean'] = { style = 'italic', fg = 'palette.orange' },
        },
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

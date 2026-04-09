local term_transparency = not vim.g.neovide and os.getenv 'TERM_TRANSPARENCY' == 'true'

vim.g.neovide_title_background_color = string.format('%x', vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name 'Normal' }).bg)

return {
  -- colorsaver automatically save/loads the last used color scheme
  {
    'https://git.sr.ht/~swaits/colorsaver.nvim',
    lazy = true,
    event = 'VimEnter',
    opts = {},
    dependencies = {
      {
        'catppuccin/nvim',
        name = 'catppuccin',
        opts = {
          transparent_background = term_transparency,
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
        opts = {
          style = 'moon',
          transparent = term_transparency,
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
        name = 'rose-pine',
        opts = {
          variant = 'auto',
          dark_variant = 'moon',
          styles = {
            transparency = term_transparency,
          },
        },
      },
      {
        'EdenEast/nightfox.nvim',
        opts = {
          options = {
            transparent = term_transparency,
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
      {
        'samharju/synthweave.nvim',
        config = function()
          local synthweave = require 'synthweave'
          synthweave.setup()
          synthweave.load()
        end,
      },
    },
  },
}

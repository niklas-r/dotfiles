---@type blink.cmp.WindowBorder
local border = 'rounded'

return {
  {
    'saghen/blink.cmp',

    event = 'InsertEnter',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'fang2hou/blink-copilot',
      'Kaiser-Yang/blink-cmp-avante',
    },

    -- use a release tag to download pre-built binaries
    version = '*',

    config = function(_, opts)
      vim.g.blink_cmp_enabled = true

      require('blink.cmp').setup(opts)
    end,

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        return not vim.tbl_contains({ 'bigfile', 'dotenv' }, vim.bo.filetype)
          and vim.g.blink_cmp_enabled
          and vim.bo.buftype ~= 'prompt'
          and vim.b.completion ~= false
      end,
      completion = {
        menu = {
          border = border,
          draw = {
            -- columns = {
            --   { 'label', 'label_description', gap = 1 },
            --   { 'kind_icon', 'kind' },
            -- },
            treesitter = { 'lsp' },
          },
        },
        documentation = {
          window = {
            border = border,
          },
        },
        list = {
          selection = {
            auto_insert = false,
            preselect = false,
          },
        },
        trigger = {
          show_on_insert_on_trigger_character = false,
        },
      },
      cmdline = {
        keymap = {
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
          ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
          ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        },
        completion = {
          list = {
            selection = {
              auto_insert = false,
              preselect = false,
            },
          },
          menu = {
            auto_show = true,
          },
          ghost_text = { enabled = true },
        },
      },

      keymap = {
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-d>'] = { 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-y>'] = { 'accept', 'fallback' },

        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },

        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        use_nvim_cmp_as_default = true,

        nerd_font_variant = 'normal',
        kind_icons = {
          Class = '',
          Color = '',
          Constant = '',
          Constructor = '',
          Copilot = '',
          Enum = '',
          EnumMember = '',
          Event = '',
          Field = '',
          File = '',
          Folder = '',
          Function = '',
          Interface = '',
          Keyword = '',
          Method = '',
          Module = '',
          Operator = '',
          Property = '',
          Reference = '',
          Snippet = '',
          Struct = '',
          Text = '',
          TypeParameter = '',
          Unit = '',
          Value = '',
          Variable = '',
        },
      },
      sources = {
        default = {
          'lsp',
          'path',
          'snippets',
          'buffer',
          'copilot',
          'lazydev',
          'avante',
        },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
            -- Optional settings
            opts = {
              max_completions = 1,
              max_attempts = 2,
            },
          },
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', fallbacks = { 'lsp' } },
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {
              kind_icons = {
                AvanteCmd = '',
                AvanteMention = '',
              },
              avante = {
                command = {
                  get_kind_name = function(_)
                    return 'AvanteCmd'
                  end,
                },
                mention = {
                  get_kind_name = function(_)
                    return 'AvanteMention'
                  end,
                },
              },
            },
          },
        },
      },

      -- experimental signature help support
      signature = { enabled = false },
    },
    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { 'sources.default' },
  },
}

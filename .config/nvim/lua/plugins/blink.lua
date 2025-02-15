---@type blink.cmp.WindowBorder
local border = 'rounded'

---@param new_item string
---@param items blink.cmp.CompletionItem[]
---@return blink.cmp.CompletionItem[]
local add_completion_kind_item = function(new_item, items)
  local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
  local kind_idx = #CompletionItemKind + 1
  CompletionItemKind[kind_idx] = new_item

  for _, item in ipairs(items) do
    item.kind = kind_idx
  end
  return items
end

return {
  -- add blink.compat to be used with Avante commands
  {
    'saghen/blink.compat',
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    version = '*',
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    opts = {},
  },
  {
    'saghen/blink.cmp',
    lazy = false, -- lazy loading handled internally
    -- optional: provides snippets for the snippet source
    dependencies = {
      'rafamadriz/friendly-snippets',
      'giuxtaposition/blink-cmp-copilot',
      'saghen/blink.compat',
    },

    -- use a release tag to download pre-built binaries
    version = '*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
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
          AvanteCommand = '',
          AvanteFile = '',
          AvanteMention = '󰁥',
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
          'avante_commands',
          'avante_files',
          'avante_mentions',
        },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 120,
            async = true,
            transform_items = function(_, items)
              return add_completion_kind_item('Copilot', items)
            end,
          },
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', fallbacks = { 'lsp' } },
          avante_commands = {
            name = 'avante_commands',
            module = 'blink.compat.source',
            score_offset = 90, -- show at a higher priority than lsp
            opts = {},
            transform_items = function(_, items)
              return add_completion_kind_item('AvanteCommand', items)
            end,
          },
          avante_files = {
            name = 'avante_files',
            module = 'blink.compat.source',
            score_offset = 100, -- show at a higher priority than lsp
            opts = {},
            transform_items = function(_, items)
              return add_completion_kind_item('AvanteFile', items)
            end,
          },
          avante_mentions = {
            name = 'avante_mentions',
            module = 'blink.compat.source',
            score_offset = 110, -- show at a higher priority than lsp
            opts = {},
            transform_items = function(_, items)
              return add_completion_kind_item('AvanteMention', items)
            end,
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

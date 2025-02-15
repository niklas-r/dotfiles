---@type blink.cmp.WindowBorder
local border = 'rounded'

return {
  'saghen/blink.cmp',
  lazy = false, -- lazy loading handled internally
  -- optional: provides snippets for the snippet source
  dependencies = {
    'rafamadriz/friendly-snippets',
    'giuxtaposition/blink-cmp-copilot',
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
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind_icon', 'kind' },
          },
        },
      },
      documentation = {
        window = {
          border = border,
        },
      },
      list = {
        selection = 'manual',
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
        Copilot = '',
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

    -- default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, via `opts_extend`
    sources = {
      -- This is for an upcoming release of blink
      default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot', 'lazydev' },
      -- optionally disable cmdline completions
      -- cmdline = {},
      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-cmp-copilot',
          score_offset = 100,
          async = true,
          transform_items = function(_, items)
            local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
            local kind_idx = #CompletionItemKind + 1
            CompletionItemKind[kind_idx] = 'Copilot'

            for _, item in ipairs(items) do
              item.kind = kind_idx
            end
            return items
          end,
        },
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', fallbacks = { 'lsp' } },
      },
    },

    -- experimental signature help support
    -- signature = { enabled = true },
  },
  -- allows extending the providers array elsewhere in your config
  -- without having to redefine it
  opts_extend = { 'sources.default' },
}

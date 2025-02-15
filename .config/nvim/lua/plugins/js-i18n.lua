vim.g.js_i18n_enabled = false

return {
  'nabekou29/js-i18n.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
  },
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    primary_language = { 'en' }, -- The default language to display (initial setting for displaying virtual text, etc.)
    translation_source = { '**/{locales,messages}/**/*.json' }, -- Pattern for translation resources
    virt_text = {
      enabled = false, -- Disabled by default, can be toggle with Snacks
    },
    diagnostic = {
      enabled = false,
    },
  },
}

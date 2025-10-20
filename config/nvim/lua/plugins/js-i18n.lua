return {
  'nabekou29/js-i18n.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
  },
  cmd = { 'I18nVirtualTextEnable' }, -- Lazy load on command
  opts = {
    primary_language = { 'en' }, -- The default language to display (initial setting for displaying virtual text, etc.)
    translation_source = { '**/{locales,messages}/**/*.json' }, -- Pattern for translation resources
    virt_text = {
      enabled = true,
    },
    diagnostic = {
      enabled = true,
    },
  },
  init = function()
    local enabled = false

    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      once = true,
      callback = function()
        if require 'snacks' ~= nil then
          require('snacks')
            .toggle({
              name = 'i18n virtual text',
              get = function()
                return enabled
              end,
              set = function(state)
                if state then
                  vim.cmd 'I18nVirtualTextEnable'
                  vim.cmd 'I18nDiagnosticEnable'
                  vim.keymap.set('n', '<leader>ct', '<CMD>:I18nEditTranslation<CR>', { desc = 'I18n: Edit [T]ranslation', silent = true })
                else
                  vim.cmd 'I18nVirtualTextDisable'
                  vim.cmd 'I18nDiagnosticDisable'
                  vim.keymap.del('n', '<leader>ct')
                end
                enabled = state
              end,
            })
            :map '<leader>ti'
        end
      end,
    })
  end,
}

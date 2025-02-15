return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  depenencies = {
    'folke/which-key.nvim',
    'tadaa/vimade',
  },
  opts = {
    toggle = {},
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>ts'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>tw'
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>tr'
        Snacks.toggle.diagnostics():map '<leader>td'
        Snacks.toggle.line_number():map '<leader>tl'
        Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>tC'
        Snacks.toggle.treesitter():map '<leader>tT'
        -- Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>tb'
        Snacks.toggle.inlay_hints():map '<leader>th'
        Snacks.toggle.indent():map '<leader>tg'
        Snacks.toggle.dim():map '<leader>tD'
        Snacks.toggle.zen():map '<leader>tz'
        Snacks.toggle.zoom():map '<leader>tZ'

        -- Plugin toggles

        -- LSP toggles
        Snacks.toggle({
          name = 'LSP Lines',
          get = function()
            return vim.diagnostic.config().virtual_lines
          end,
          set = function()
            require('lsp_lines').toggle()
          end,
        }):map '<leader>tL'

        -- Git toggles
        Snacks.toggle({
          name = 'git blame line',
          get = function()
            return require('gitsigns.config').config.current_line_blame
          end,
          set = function()
            require('gitsigns').toggle_current_line_blame()
          end,
        }):map '<leader>tB'

        Snacks.toggle({
          name = 'git show deleted',
          get = function()
            return require('gitsigns.config').config.show_deleted
          end,
          set = function()
            require('gitsigns').toggle_deleted()
          end,
        }):map '<leader>td'

        -- Buffer effects
        Snacks.toggle({
          name = 'dimming inactive panes',
          get = function()
            return vim.g.vimade_enabled
          end,
          set = function(state)
            if state then
              vim.cmd 'VimadeEnable'
            else
              vim.cmd 'VimadeDisable'
            end
            vim.g.vimade_enabled = state
          end,
        }):map '<leader>tp'

        Snacks.toggle({
          name = 'centered mode',
          get = function()
            return vim.g.centered_layout_enabled
          end,
          set = function(state)
            vim.cmd 'NoNeckPain'
            vim.g.centered_layout_enabled = state
          end,
        }):map '<leader>tc'
      end,
    })
  end,
}

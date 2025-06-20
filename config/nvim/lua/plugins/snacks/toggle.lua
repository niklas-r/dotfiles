return {
  'folke/snacks.nvim',
  depenencies = {
    'nabekou29/js-i18n.nvim',
    'tadaa/vimade',
    'lewis6991/gitsigns.nvim',
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
            -- Hacky bool cast
            return not not vim.diagnostic.config().virtual_lines
          end,
          set = function(state)
            vim.diagnostic.config {
              virtual_lines = state,
            }
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
        }):map '<leader>tb'

        Snacks.toggle({
          name = 'Git Signs',
          get = function()
            return require('gitsigns.config').config.signcolumn
          end,
          set = function(state)
            require('gitsigns').toggle_signs(state)
          end,
        }):map '<leader>tG'

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

        -- Various
        Snacks.toggle({
          name = 'auto-completion',
          get = function()
            return vim.g.blink_cmp_enabled
          end,
          set = function(state)
            if state then
              vim.cmd [[Copilot enable]]
            else
              vim.cmd [[Copilot disable]]
            end
            vim.g.copilot_enabled = state
            vim.g.blink_cmp_enabled = state
          end,
        }):map '<leader>ta'

        Snacks.toggle({
          name = 'AI Copilot',
          get = function()
            return vim.g.copilot_enabled
          end,
          set = function(state)
            if state then
              vim.cmd [[Copilot enable]]
            else
              vim.cmd [[Copilot disable]]
            end
            vim.g.copilot_enabled = state
          end,
        }):map '<leader>tA'
      end,
    })
  end,
}

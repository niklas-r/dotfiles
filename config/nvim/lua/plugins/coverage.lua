vim.g.display_code_coverage = false

return {
  'andythigpen/nvim-coverage',
  version = '*',
  dependencies = {
    'folke/which-key.nvim',
    'folke/snacks.nvim',
  },
  cmd = { 'Coverage', 'CoverageLoad', 'CoverageLoadLcov', 'CoverageShow', 'CoverageHide', 'CoverageToggle', 'CoverageClear', 'CoverageSummary' },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        require('which-key').add {
          { '<leader>uc', group = '[C]ode coverage' },
        }

        Snacks.toggle({
          name = 'code coverage',
          get = function()
            return vim.g.display_code_coverage
          end,
          set = function(state)
            if state then
              vim.cmd 'Coverage'
            else
              vim.cmd 'CoverageClear'
            end

            vim.g.display_code_coverage = state
          end,
        }):map '<leader>uct'
      end,
    })
  end,
  keys = {
    {
      '<leader>ucs',
      '<CMD>CoverageSummary<CR>',
      desc = '[S]ummary',
    },
  },
  opts = {
    auto_reload = true,
    oad_coverage_cb = function(ftype)
      vim.notify('Loaded ' .. ftype .. ' coverage')
    end,
  },
}

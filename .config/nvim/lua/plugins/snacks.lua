return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  -- import snacks subdirectory with broken up snacks plugin specs
  import = 'plugins/snacks',
  keys = {
    {
      '<leader>rf',
      function()
        Snacks.rename.rename_file()
      end,
      desc = 'LSP: [R]ename [F]ile',
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command
      end,
    })
  end,
  opts = {
    statuscolumn = { enabled = true },
  },
}

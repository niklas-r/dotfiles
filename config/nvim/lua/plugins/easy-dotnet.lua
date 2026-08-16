return {
  'GustavEikaas/easy-dotnet.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'folke/snacks.nvim' },
  config = function()
    require('easy-dotnet').setup {
      test_runner = {
        neotest_integration = true,
      },
    }
  end,
}

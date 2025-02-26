return {
  'folke/snacks.nvim',
  keys = {
    -- stylua: ignore start
    { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer', },
    { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer', },
    -- stylua: ignore end
  },
}

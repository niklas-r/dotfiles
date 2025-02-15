return {
  'f-person/auto-dark-mode.nvim',
  config = function()
    require('auto-dark-mode').setup { update_interval = 5000 }
  end,
}

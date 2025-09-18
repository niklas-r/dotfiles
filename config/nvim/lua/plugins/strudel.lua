local map = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = 'Strudel: ' .. desc, buffer = true })
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = { '*.str', '*.strudel.js' },
  callback = function()
    vim.schedule(function()
      local strudel = require 'strudel'
      map('<localleader>l', strudel.launch, 'Launch')
      map('<localleader>q', strudel.quit, 'Quit')
      map('<localleader>t', strudel.toggle, 'Toggle Play/Stop')
      map('<localleader>u', strudel.update, 'Update')
      map('<localleader>s', strudel.stop, 'Stop Playback')
      map('<localleader>b', strudel.set_buffer, 'set current buffer')
      map('<localleader>x', strudel.execute, 'set current buffer and update')
      map('<leader>h', strudel.execute, 'set current buffer and update')
    end)
  end,
})

return {
  'gruvw/strudel.nvim',
  build = 'npm install',
  opts = {},
  -- The plugin itself does the lazy loading
  lazy = false,
  setup = function(_, opts)
    require('strudel').setup(opts)
  end,
}

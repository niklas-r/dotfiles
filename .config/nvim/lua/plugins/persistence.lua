return {
  'folke/persistence.nvim',
  event = 'BufReadPre', -- this will only start session saving when an actual file was opened
  opts = {
    need = 1, -- minimum number of file buffers that need to be open to save
  },
  keys = {
    -- stylua: ignore start
    { '<leader>qs', function() require('persistence').load() end, desc = 'Restore Session', },
    { '<leader>qS', function() require('persistence').select() end, desc = 'Select Session', },
    { '<leader>ql', function() require('persistence').load { last = true } end, desc = 'Restore Last Session', },
    { '<leader>qd', function() require('persistence').stop() end, desc = "Don't Save Current Session", },
    -- stylua: ignore end
  },
}

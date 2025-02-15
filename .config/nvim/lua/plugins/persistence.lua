return {
  'folke/persistence.nvim',
  event = 'BufReadPre', -- this will only start session saving when an actual file was opened
  opts = {
    need = 1, -- minimum number of file buffers that need to be open to save
  },
}

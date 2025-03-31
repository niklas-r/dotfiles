return {
  {
    'topaxi/pipeline.nvim',
    keys = {
      { '<leader>cp', '<cmd>Pipeline<cr>', desc = 'Open [P]ipeline.nvim' },
    },
    event = 'VeryLazy',
    -- optional, you can also install and use `yq` instead.
    -- it requires cargo
    -- build = 'make',
    ---@type pipeline.Config
    opts = {},
  },
}

return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    signs = false,
    keywords = {
      TEST = { icon = '⏲ ', color = 'test', alt = false },
    },
    colors = {
      test = { 'DiagnosticHint', '#FF00FF' },
    },
  },
  -- Add snacks pickers
  keys = {
    {
      '<leader>st',
      function()
        Snacks.picker.todo_comments()
      end,
      desc = '[S]earch [T]odo',
    },
    {
      '<leader>sT',
      function()
        Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME' } }
      end,
      desc = '[S]earch [T]odo/Fix/Fixme',
    },
  },
}

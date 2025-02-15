return {
  'rachartier/tiny-code-action.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope.nvim' },
  },
  event = 'LspAttach',
  keys = {
    {
      '<leader>ca',
      function()
        -- It works without the missing parameter, time will tell if this is a good idea or not
        ---@diagnostic disable-next-line: missing-parameter
        require('tiny-code-action').code_action()
      end,
      { 'n', 'x' },
      noremap = true,
      silent = true,
      desc = '[C]ode [A]ction',
    },
  },
  opts = {
    backend = 'delta',
    backend_opts = {
      delta = {
        -- Header from delta can be quite large.
        -- You can remove them by setting this to the number of lines to remove
        header_lines_to_remove = 4,

        -- The arguments to pass to delta
        -- If you have a custom configuration file, you can set the path to it like so:
        -- args = {
        --     "--config" .. os.getenv("HOME") .. "/.config/delta/config.yml",
        -- }
        args = {
          '--line-numbers',
        },
      },
    },
  },
}

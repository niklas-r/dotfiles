return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        bigfile = false,
        dotenv = false,
        pem = false,
      },
    },
    dependencies = {},
    config = function(_, opts)
      vim.g.copilot_enabled = true

      require('copilot').setup(opts)
    end,
  },
}

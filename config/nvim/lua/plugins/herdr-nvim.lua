return {
  'ChmaraX/herdr-nvim',
  cond = vim.env.HERDR_ENV == '1',
  opts = {
    prefix = '<leader>a',
    keymaps = true,
    clear_after_send = true,
  },
}

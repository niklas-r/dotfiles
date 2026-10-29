return {
  'ChmaraX/herdr-nvim',
  cond = vim.env.HERDR_ENV == '1',
  -- Keymaps live here instead of the plugin's `keymaps = true`: the herdr sidebar
  -- daemon calls setup() again on VimEnter, which warned about every map it had
  -- already created.
  keys = {
    { '<leader>ac', function() require('herdr-nvim').comment_line() end, desc = 'herdr-nvim: comment line' },
    { '<leader>ac', function() require('herdr-nvim').comment_selection() end, mode = 'x', desc = 'herdr-nvim: comment selection' },
    { '<leader>al', function() require('herdr-nvim').list_comments() end, desc = 'herdr-nvim: list comments' },
    { '<leader>as', function() require('herdr-nvim').send_all { submit = false } end, desc = 'herdr-nvim: paste comments to agent' },
    { '<leader>aS', function() require('herdr-nvim').send_all { submit = true } end, desc = 'herdr-nvim: send comments to agent' },
    { '<leader>ai', function() require('herdr-nvim').ref_line() end, desc = 'herdr-nvim: reference line at agent cursor' },
    { '<leader>ai', function() require('herdr-nvim').ref_selection() end, mode = 'x', desc = 'herdr-nvim: reference selection at agent cursor' },
  },
  opts = {
    keymaps = false,
    clear_after_send = true,
  },
}

return {
  'karb94/neoscroll.nvim',
  event = 'BufReadPre',
  opts = {
    -- hide_cursor = false,
    easing = 'quadratic', -- Options: linear, quadratic, cubic, quartic, quintic, circular, sine
    post_hook = function()
      vim.cmd 'normal! zz'
    end,
  },
}

return {
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  keys = {
    {
      '<Leader>L',
      function()
        require('lsp_lines').toggle()
      end,
      desc = 'Toggle [L]SP lines',
    },
  },
  opts = {},
}

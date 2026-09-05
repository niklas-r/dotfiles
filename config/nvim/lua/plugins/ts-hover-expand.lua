local ft = { 'typescript', 'typescriptreact' }

return {
  'nemanjamalesija/ts-expand-hover.nvim',
  ft = ft,
  -- Disable the plugin's own global K; we map it per-buffer below instead.
  opts = { keymaps = { hover = false } },
  keys = {
    {
      'K',
      function()
        require('ts_expand_hover').hover()
      end,
      ft = ft,
      desc = 'TypeScript expandable hover',
    },
  },
}

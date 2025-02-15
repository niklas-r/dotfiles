return {
  'folke/snacks.nvim',
  opts = {
    indent = {
      enabled = true,
      priority = 1,
      animate = {
        enabled = false,
      },
      scope = {
        enabled = true,
      },
      -- filter for buffers to enable indent guides
      filter = function(buf)
        return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ''
      end,
    },
  },
}

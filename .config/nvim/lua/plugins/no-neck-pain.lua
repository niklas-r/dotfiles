-- Used by Snacks.toggle
vim.g.centered_layout_enabled = false

return {
  'shortcuts/no-neck-pain.nvim',
  version = '*',
  opts = {
    width = 120,
    integrations = {
      -- By default, if NeoTree is open, we will close it and reopen it when enabling the plugin,
      -- this prevents having the side buffers wrongly positioned.
      -- @link https://github.com/nvim-neo-tree/neo-tree.nvim
      NeoTree = {
        -- The position of the tree.
        --- @type "left"|"right"
        position = 'left',
        -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
        reopen = true,
      },
      -- @link https://github.com/mbbill/undotree
      undotree = {
        -- The position of the tree.
        --- @type "left"|"right"
        position = 'left',
      },
      -- @link https://github.com/nvim-neotest/neotest
      neotest = {
        -- The position of the tree.
        --- @type "right"
        position = 'right',
        -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
        reopen = true,
      },
      -- @link https://github.com/nvim-treesitter/playground
      TSPlayground = {
        -- The position of the tree.
        --- @type "right"|"left"
        position = 'right',
        -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
        reopen = true,
      },
      -- @link https://github.com/rcarriga/nvim-dap-ui
      NvimDAPUI = {
        -- The position of the tree.
        --- @type "none"
        position = 'none',
        -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
        reopen = true,
      },
      -- @link https://github.com/hedyhli/outline.nvim
      outline = {
        -- The position of the tree.
        --- @type "left"|"right"
        position = 'right',
        -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
        reopen = true,
      },
    },
  },
}

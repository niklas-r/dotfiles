return {
  'retran/meow.yarn.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  event = { 'LspAttach' },
  config = function()
    local yarn = require 'meow.yarn'
    yarn.setup()

    local open = yarn.open_tree
    local mapping = function(lhs, hierarchy_type, cmd, desc)
      vim.keymap.set('n', lhs, function()
        open(hierarchy_type, cmd)
      end, { desc = desc })
    end

    mapping('<leader>yt', 'type_hierarchy', 'supertypes', 'Type Hierarchy (Super)')
    mapping('<leader>yT', 'type_hierarchy', 'subtypes', 'Type Hierarchy (Sub)')
    mapping('<leader>yc', 'call_hierarchy', 'callers', 'Call Hierarchy (Callers)')
    mapping('<leader>yC', 'call_hierarchy', 'callees', 'Call Hierarchy (Callees)')
  end,
}

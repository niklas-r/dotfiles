return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local harpoon = require 'harpoon'

    -- Required!
    harpoon:setup()

    -- Open in split or tab
    harpoon:extend {
      UI_CREATE = function(cx)
        vim.keymap.set('n', '<C-v>', function()
          harpoon.ui:select_menu_item { vsplit = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-s>', function()
          harpoon.ui:select_menu_item { split = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-t>', function()
          harpoon.ui:select_menu_item { tabedit = true }
        end, { buffer = cx.bufnr })
      end,
    }
  end,
  keys = {
    {
      '<leader>ml',
      function()
        local harpoon = require 'harpoon'
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = 'Harpoon [M]arks [L]ist',
    },
    -- stylua: ignore start
    { '<leader>ma', function() require('harpoon'):list():add() end,     desc = 'Harpoon [M]arks [A]dd File' },
    { '<leader>mn', function() require('harpoon'):list():next() end,    desc = 'Harpoon [M]arks [N]ext' },
    { '<leader>mp', function() require('harpoon'):list():prev() end,    desc = 'Harpoon [M]arks [P]rev' },

    -- Nav to N file
    { '<M-a>', function() require('harpoon'):list():select(1) end, desc = 'Harpoon [M]arks File [1]' },
    { '<M-s>', function() require('harpoon'):list():select(2) end, desc = 'Harpoon [M]arks File [2]' },
    { '<M-d>', function() require('harpoon'):list():select(3) end, desc = 'Harpoon [M]arks File [3]' },
    { '<M-f>', function() require('harpoon'):list():select(4) end, desc = 'Harpoon [M]arks File [4]' },
    { '<M-g>', function() require('harpoon'):list():select(5) end, desc = 'Harpoon [M]arks File [5]' },
    -- stylua: ignore end
  },
}

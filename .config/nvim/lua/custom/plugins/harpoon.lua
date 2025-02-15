return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- "nvim-telescope/telescope.nvim"
  },
  config = function()
    local harpoon = require 'harpoon'

    -- Required!
    harpoon:setup()

    -- Harpoon Telescope extension
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set('n', '<leader>sm', function()
      toggle_telescope(harpoon:list())
    end, { desc = '[S]earch Harpoon [M]arks' })

    -- Open in split or tab
    harpoon:extend {
      UI_CREATE = function(cx)
        vim.keymap.set('n', '<C-v>', function()
          harpoon.ui:select_menu_item { vsplit = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-x>', function()
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
    { '<leader>m1', function() require('harpoon'):list():select(1) end, desc = 'Harpoon [M]arks File [1]' },
    { '<leader>m2', function() require('harpoon'):list():select(2) end, desc = 'Harpoon [M]arks File [2]' },
    { '<leader>m3', function() require('harpoon'):list():select(3) end, desc = 'Harpoon [M]arks File [3]' },
    { '<leader>m4', function() require('harpoon'):list():select(4) end, desc = 'Harpoon [M]arks File [4]' },
    { '<leader>m5', function() require('harpoon'):list():select(5) end, desc = 'Harpoon [M]arks File [5]' },
    { '<leader>m6', function() require('harpoon'):list():select(6) end, desc = 'Harpoon [M]arks File [6]' },
    { '<leader>m7', function() require('harpoon'):list():select(7) end, desc = 'Harpoon [M]arks File [7]' },
    { '<leader>m8', function() require('harpoon'):list():select(8) end, desc = 'Harpoon [M]arks File [8]' },
    { '<leader>m9', function() require('harpoon'):list():select(9) end, desc = 'Harpoon [M]arks File [9]' },
    -- stylua: ignore end
  },
}

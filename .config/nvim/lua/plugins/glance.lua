return {
  'dnlhc/glance.nvim',
  event = 'LspAttach',
  keys = {
    { '<leader>pr', '<CMD>Glance references<CR>', desc = '[R]eferences' },
    { '<leader>pd', '<CMD>Glance definitions<CR>', desc = '[D]efinitions' },
    { '<leader>pD', '<CMD>Glance type_definitions<CR>', desc = 'Type [D]efinitions' },
    { '<leader>pI', '<CMD>Glance implementations<CR>', desc = '[I]mplementations' },
    { '<leader>p.', '<CMD>Glance resume<CR>', desc = 'Resume' },
  },
  opts = {
    use_trouble_qf = true,
  },
  config = function(_, opts)
    local glance = require 'glance'
    glance.setup(opts)
    -- local wk = require('which-key')
    -- mappings = {
    --   list = {
    --     ['j'] = actions.next, -- Bring the cursor to the next item in the list
    --     ['k'] = actions.previous, -- Bring the cursor to the previous item in the list
    --     ['<Down>'] = actions.next,
    --     ['<Up>'] = actions.previous,
    --     ['<Tab>'] = actions.next_location, -- Bring the cursor to the next location skipping groups in the list
    --     ['<S-Tab>'] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
    --     ['<C-u>'] = actions.preview_scroll_win(5),
    --     ['<C-d>'] = actions.preview_scroll_win(-5),
    --     ['v'] = actions.jump_vsplit,
    --     ['s'] = actions.jump_split,
    --     ['t'] = actions.jump_tab,
    --     ['<CR>'] = actions.jump,
    --     ['o'] = actions.jump,
    --     ['l'] = actions.open_fold,
    --     ['h'] = actions.close_fold,
    --     ['<leader>l'] = actions.enter_win('preview'), -- Focus preview window
    --     ['q'] = actions.close,
    --     ['Q'] = actions.close,
    --     ['<Esc>'] = actions.close,
    --     ['<C-q>'] = actions.quickfix,
    --     -- ['<Esc>'] = false -- disable a mapping
    --   },
    --   preview = {
    --     ['Q'] = actions.close,
    --     ['<Tab>'] = actions.next_location,
    --     ['<S-Tab>'] = actions.previous_location,
    --     ['<leader>l'] = actions.enter_win('list'), -- Focus list window
    --   },
    -- },
    -- wk.add(mappings, opts?)
  end,
}

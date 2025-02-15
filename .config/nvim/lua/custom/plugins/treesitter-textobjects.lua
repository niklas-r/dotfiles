return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  event = 'VeryLazy',
  setup = function()
    require('nvim-treesitter.configs').setup {
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['am'] = { query = '@function.outer', desc = '[A]round [M]ethod' },
            ['im'] = { query = '@function.inner', desc = '[I]n [M]ethod' },
            ['ac'] = { query = '@class.outer', desc = '[A]round [C]lass' },
            -- You can optionally set descriptions to the mappings (used in the desc parameter of
            -- nvim_buf_set_keymap) which plugins like which-key display
            ['ic'] = { query = '@class.inner', desc = '[I]n [C]lass' },
            -- You can also use captures from other query groups like `locals.scm`
            ['as'] = { query = '@local.scope', query_group = 'locals', desc = '[A]round [S]cope' },
          },
          -- You can choose the select mode (default is charwise 'v')
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * method: eg 'v' or 'o'
          -- and should return the mode ('v', 'V', or '<c-v>') or a table
          -- mapping query_strings to modes.
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = 'V',
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * selection_mode: eg 'v'
          -- and should return true or false
          include_surrounding_whitespace = true,
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>np'] = { query = '@parameter.inner', desc = 'Swap with next [P]arameter' },
            ['<leader>nm'] = { query = '@function.outer' },
            desc = 'Swap with next [M]ethod',
          },
          swap_previous = {
            ['<leader>pp'] = { query = '@parameter.inner', desc = 'Swap with prev [P]arameter' },
            ['<leader>pm'] = { query = '@function.outer' },
            desc = 'Swap with prev [M]ethod',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = { query = '@function.outer', desc = 'Next [M]ethod' },
            [']c'] = { query = '@class.outer', desc = 'Next [C]lass' },
            --
            -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
            [']o'] = { query = '@loop.*', desc = 'Next L[o]op' },
            -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
            --
            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            [']s'] = { query = '@local.scope', query_group = 'locals', desc = 'Next [S]cope' },
            [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next [F]old' },
          },
          goto_next_end = {
            [']M'] = { query = '@function.outer', desc = 'Next [M]ethod end' },
            [']C'] = { query = '@class.outer', desc = 'Next [C]lass end' },
          },
          goto_previous_start = {
            ['[f'] = { query = '@function.outer', desc = 'Prev [M]ethod' },
            ['[c'] = { query = '@class.outer', desc = 'Prev [C]lass' },
          },
          goto_previous_end = {
            ['[M'] = { query = '@function.outer', desc = 'Prev [M]ethod end' },
            ['[C'] = { query = '@class.outer', desc = 'Prev [C]lass end' },
          },
          -- Below will go to either the start or the end, whichever is closer.
          -- Use if you want more granular movements
          -- Make it even more gradual by adding multiple queries and regex.
          goto_next = {
            [']n'] = { query = '@conditional.outer', desc = 'Next co[N]dition' },
          },
          goto_previous = {
            ['[n'] = { query = '@conditional.outer', desc = 'Prev co[N]dition' },
          },
        },
      },
    }

    local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'

    -- Repeat movement with ; and ,
    -- ensure ; goes forward and , goes backward regardless of the last direction
    vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

    -- vim way: ; goes to the direction you were moving.
    -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
    -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

    -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
    vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })
  end,
}

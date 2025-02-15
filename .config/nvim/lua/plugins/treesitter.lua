return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPre', 'BufNewFile' },
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  dependencies = {
    -- 'nvim-treesitter/nvim-treesitter-context',
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  opts = {
    ensure_installed = {
      'json',
      'yaml',
      'javascript',
      'typescript',
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'gitignore',
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    incremental_selection = {
      -- FIXME: Disabled this because it breaks <C-i> for some reason
      enable = false,
      keymaps = {
        init_selection = '<Tab>',
        node_incremental = '<Tab>',
        scope_incremental = false,
        node_decremental = '<S-Tab>',
      },
    },
    indent = { enable = true, disable = { 'ruby' } },
    textobjects = {
      lsp_interop = {
        enable = true,
        border = 'none',
        floating_preview_opts = { border = 'rounded' },
      },
      select = {
        enable = false, -- disable due to usage of mini.ai

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        -- Extra mappings that can be used with mini.surround and mini.ai
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['am'] = { query = '@function.outer', desc = 'around method' },
          ['im'] = { query = '@function.inner', desc = 'in method' },
          ['ac'] = { query = '@class.outer', desc = 'around class' },
          -- You can optionally set descriptions to the mappings (used in the desc parameter of
          -- nvim_buf_set_keymap) which plugins like which-key display
          ['ic'] = { query = '@class.inner', desc = 'in class' },
          -- You can also use captures from other query groups like `locals.scm`
          ['as'] = { query = '@local.scope', query_group = 'locals', desc = 'around scope' },
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
          ['<leader>Sp'] = { query = '@parameter.inner', desc = '[S]wap with next [P]arameter' },
          ['<leader>Sm'] = { query = '@function.outer', desc = '[S]wap with next [M]ethod' },
        },
        swap_previous = {
          ['<leader>SP'] = { query = '@parameter.inner', desc = '[S]wap with prev [P]arameter' },
          ['<leader>SM'] = { query = '@function.outer', desc = '[S]wap with prev [M]ethod' },
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = { query = '@function.outer', desc = 'Next [M]ethod' },
          [']c'] = { query = '@class.outer', desc = 'Next [C]lass' },
          [']o'] = { query = '@loop.*', desc = 'Next L[o]op' },
          [']s'] = { query = '@local.scope', query_group = 'locals', desc = 'Next [S]cope' },
          [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next [F]old' },
        },
        goto_next_end = {
          [']M'] = { query = '@function.outer', desc = 'Next [M]ethod end' },
          [']C'] = { query = '@class.outer', desc = 'Next [C]lass end' },
        },
        goto_previous_start = {
          ['[m'] = { query = '@function.outer', desc = 'Prev [M]ethod' },
          ['[c'] = { query = '@class.outer', desc = 'Prev [C]lass' },
          ['[o'] = { query = '@loop.*', desc = 'Prev L[o]op' },
          ['[s'] = { query = '@local.scope', query_group = 'locals', desc = 'Prev [S]cope' },
          ['[z'] = { query = '@fold', query_group = 'folds', desc = 'Prev [F]old' },
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
  },
}

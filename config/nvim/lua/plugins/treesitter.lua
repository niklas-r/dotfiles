return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false, -- TS no longer supprots lazy loading
    branch = 'main',
    config = function()
      -- replicate `ensure_installed`, runs asynchronously, skips existing languages
      local languages = {
        'json',
        'yaml',
        'toml',
        'javascript',
        'jsx',
        'typescript',
        'tsx',
        'bash',
        'c',
        'diff',
        'gitcommit',
        'html',
        'css',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'gitignore',
        'regex',
      }

      require('nvim-treesitter').install(languages)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter.setup', {}),
        callback = function(args)
          local buf = args.buf
          local filetype = args.match

          -- you need some mechanism to avoid running on buffers that do not
          -- correspond to a language (like oil.nvim buffers), this implementation
          -- checks if a parser exists for the current language
          local language = vim.treesitter.language.get_lang(filetype) or filetype
          if not vim.treesitter.language.add(language) then
            return
          end

          -- replicate `fold = { enable = true }`
          vim.wo.foldmethod = 'expr'
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

          -- replicate `highlight = { enable = true }`
          vim.treesitter.start(buf, language)

          -- replicate `indent = { enable = true }`
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'VeryLazy',
    opts = {
      auto_install = true,
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    keys = function()
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      return {
        {
          ']z',
          function()
            move.goto_next_start('@fold', 'folds')
          end,
          desc = 'Next Fold',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[z',
          function()
            move.goto_previous_start('@fold', 'folds')
          end,
          desc = 'Prev Fold',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[m',
          function()
            move.goto_previous_start('@function.outer', 'textobjects')
          end,
          desc = 'Prev [M]ethod',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']m',
          function()
            move.goto_next_start('@function.outer', 'textobjects')
          end,
          desc = 'Next [M]ethod',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[M',
          function()
            move.goto_previous_end('@function.outer', 'textobjects')
          end,
          desc = 'Prev [M]ethod end',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']M',
          function()
            move.goto_next_end('@function.outer', 'textobjects')
          end,
          desc = 'Next [M]ethod end',
          mode = { 'n', 'x', 'o' },
        },
        {
          '<leader>wpl',
          function()
            swap.swap_next '@parameter.inner'
          end,
          desc = '',
        },
        {
          '<leader>wph',
          function()
            swap.swap_previous '@parameter.inner'
          end,
          desc = '',
        },
        {
          '<leader>wmj',
          function()
            swap.swap_next '@function.outer'
          end,
          desc = '',
        },
        {
          '<leader>wmk',
          function()
            swap.swap_previous '@function.outer'
          end,
          desc = '',
        },
      }
    end,
    opts = {
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
      },
      swap = {
        enable = true,
      },
      select = {
        enable = false, -- disable due to usage of mini.ai
      },
    },
  },
}

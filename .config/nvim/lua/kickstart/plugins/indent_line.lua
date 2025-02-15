return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      exclude = {
        buftypes = {
          'terminal',
        },
        filetypes = {
          '',
          'norg',
          'help',
          'markdown',
          'dapui_scopes',
          'dapui_stacks',
          'dapui_watches',
          'dapui_breakpoints',
          'dapui_hover',
          'dap-repl',
          'LuaTree',
          'dbui',
          'term',
          'fugitive',
          'fugitiveblame',
          'NvimTree',
          'packer',
          'neotest-summary',
          'Outline',
          'lsp-installer',
          'mason',
        },
      },
    },
  },
}

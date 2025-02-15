return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show { global = false }
      end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
    {
      '<leader>t',
      function()
        -- Show hydra mode for toggles
        require('which-key').show {
          keys = '<leader>t',
          -- Unfortunately the "hydra" mode is very bugged
          -- loop = true, -- this will keep the popup open until you hit <esc>
        }
      end,
      desc = '[T]oggles',
    },
  },
  opts = {
    icons = {
      -- set icon mappings to true if you have a Nerd Font
      mappings = vim.g.have_nerd_font,
      -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
      -- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },

    preset = 'modern',

    spec = {
      { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>m', group = 'Harpoon [M]arks', mode = { 'n' } },
      { '<leader>u', group = '[U]nit Test', mode = { 'n' } },
      { '<leader>ud', group = '[U]nit Test [D]ebug', mode = { 'n' } },
      { '<leader>ur', group = '[U]nit Test [R]un', mode = { 'n' } },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { '<leader>x', group = '[X] Trouble' },
      { '<leader>S', group = '[S]wap' },
      { '<leader>g', group = '[G]lance' },
      { '<leader>l', group = '[L]azygit' },
      { '<leader>a', group = '[A]I' },
    },
  },
}

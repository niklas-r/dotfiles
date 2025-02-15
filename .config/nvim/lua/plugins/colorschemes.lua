return {
  { 'catppuccin/nvim' },
  { 'folke/tokyonight.nvim' },
  { 'rebelot/kanagawa.nvim' },
  { 'shatur/neovim-ayu' },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    opts = {
      variant = 'auto',
      dark_variant = 'moon',
      styles = {
        transparency = true,
      },
    },
  },
  -- colorsaver automatically save/loads the last used color scheme
  {
    'https://git.sr.ht/~swaits/colorsaver.nvim',
    lazy = true,
    event = 'VimEnter',
    opts = {},
  },
}

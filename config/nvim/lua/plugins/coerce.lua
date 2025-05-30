-- This plugin allows us to change between different casing
return {
  'gregorias/coerce.nvim',
  config = true,
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
}

-- neotest discovers tests in a `-u NONE` child Neovim whose only source of
-- filetype -> parser mappings is `runtime! plugin/filetypes.lua`. nvim-treesitter's
-- `main` branch keeps its copy in its own plugin dir, which that child never has on
-- its runtimepath, so .tsx/.jsx specs fail with "No parser for language". This file
-- must stay at plugin/filetypes.lua to be picked up there.
vim.treesitter.language.register('tsx', { 'typescriptreact', 'typescript.tsx' })
vim.treesitter.language.register('javascript', { 'javascriptreact', 'javascript.jsx' })

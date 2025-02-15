-- Move selected lines in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Join lines and stay with cursor in same position
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines' })
-- Same but produce no space
vim.keymap.set('n', 'gJ', 'mzgJ`z', { desc = 'Join lines with no spaces' })

-- Center screen when navigating
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Yank to clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank selection to clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to clipboard' })

-- Format buffer
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format buffer' })

vim.keymap.set('x', '<leader>p', [["_dP]])

vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d')

-- vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz', { desc = 'Go next error' })
-- vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz', { desc = 'Go prev error' })
--
-- vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz', { desc = 'Go next location' })
-- vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz', { desc = 'Go prev location' })

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

return {}

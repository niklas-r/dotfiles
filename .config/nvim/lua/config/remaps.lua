-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', function()
  vim.cmd 'nohlsearch'
  -- Dismiss "notifications" from packages
  if package.loaded['notify'] ~= nil then
    require('notify').dismiss { pending = true, silent = true }
  end
  if require 'snacks' ~= nil then
    require('snacks').notifier.hide()
  end
end)

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Move selected lines in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Join lines and stay with cursor in same position
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines' })
-- Same but produce no space
vim.keymap.set('n', 'gJ', 'mzgJ`z', { desc = 'Join lines with no spaces' })

-- Center screen when navigating
-- Currently handled by animated scrolling plugin
-- vim.keymap.set('n', '<C-d>', '<C-d>zz')
-- vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Yank to clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank selection to clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to clipboard' })

-- Format buffer
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format buffer' })

-- Paste over selection and keep reg unchanged
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste over selection' })

vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Black hole delete' })

-- Don't start a macro by mistake ever again...
vim.keymap.set('n', 'q', '<Nop>')
vim.keymap.set('n', 'Q', 'q', { desc = 'Record macro' })

-- Keybinds which will get you cancelled
vim.keymap.set('n', '<C-c>', 'ciw')

vim.keymap.set('n', '<leader>bq', ':%bd!|e#<CR>', { desc = '[Q]uit all other buffers' })

return {}

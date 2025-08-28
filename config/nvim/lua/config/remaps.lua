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
-- vim.keymap.set('n', 'n', 'nzzzv')
-- vim.keymap.set('n', 'N', 'Nzzzv')

-- better up/down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Yank to clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank selection to clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to clipboard' })

-- Format buffer
-- vim.keymap.set('n', '<leader>ff', vim.lsp.buf.format, { desc = 'Format buffer' })

-- Paste over selection and keep reg unchanged
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste over selection' })

vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Black hole delete' })

-- Don't start a macro by mistake ever again...
vim.keymap.set('n', 'q', '<Nop>')
vim.keymap.set('n', 'Q', 'q', { desc = 'Record macro' })

-- Key binds which will get you cancelled
vim.keymap.set('n', '<C-c>', 'ciw')
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>', { desc = 'Save current buffer' })
vim.keymap.set('n', '<C-S-s>', '<cmd>wa<cr>', { desc = 'Save all buffers' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

-- better indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- commenting
vim.keymap.set('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Below' })
vim.keymap.set('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })

vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'Previous Quickfix' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'Next Quickfix' })

-- quit
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })
vim.keymap.set('n', '<leader>qw', '<cmd>wqa<cr>', { desc = 'Save and Quit All' })

-- tabs
vim.keymap.set('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = '[L]ast Tab' })
vim.keymap.set('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close [O]ther Tabs' })
vim.keymap.set('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = '[F]irst Tab' })
vim.keymap.set('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New [Tab]' })
vim.keymap.set('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = '[N]ext Tab' })
vim.keymap.set('n', '<leader><tab>n', '<cmd>tabnext<cr>', { desc = '[N]ext Tab' })
vim.keymap.set('n', '<leader><tab>q', '<cmd>tabclose<cr>', { desc = '[Q]uit Tab' })
vim.keymap.set('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = '[P]revious Tab' })
vim.keymap.set('n', '<leader><tab>p', '<cmd>tabprevious<cr>', { desc = '[P]revious Tab' })

-- buffers
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>bo', ':%bd!|e#<CR>', { desc = 'Close [O]ther Buffers' })

-- file
vim.keymap.set('n', '<leader>fn', '<cmd>enew<cr>', { desc = '[N]ew File' })

-- spelling
vim.keymap.set('n', ']S', ']s', { desc = 'Next bad word', noremap = true })
vim.keymap.set('n', '[S', '[s', { desc = 'Prev bad word', noremap = true })

return {}

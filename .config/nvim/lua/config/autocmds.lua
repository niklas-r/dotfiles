-- Don't add DAP buffers to list of buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dap-repl',
  callback = function(args)
    vim.api.nvim_set_option_value('buflisted', false, { buffer = args.buf })
  end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Used to display recording in lualine
-- Autocmd to track the end of macro recording
vim.api.nvim_create_autocmd('RecordingEnter', {
  pattern = '*',
  callback = function()
    vim.g.macro_recording = 'Recording @' .. vim.fn.reg_recording()
    vim.cmd 'redrawstatus'
  end,
})

-- Autocmd to track the end of macro recording
vim.api.nvim_create_autocmd('RecordingLeave', {
  pattern = '*',
  callback = function()
    vim.g.macro_recording = ''
    vim.cmd 'redrawstatus'
  end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  callback = function()
    if package.loaded['nvim-treesitter.parsers'] == nil or require 'nvim-treesitter.parsers' == nil then
      return
    end

    -- check if treesitter has parser
    if require('nvim-treesitter.parsers').has_parser() then
      -- use treesitter folding
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    else
      -- use alternative foldmethod
      vim.opt.foldmethod = 'syntax'
    end
  end,
})

return {}

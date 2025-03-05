-- Don't add DAP buffers to list of buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dap-repl',
  callback = function(args)
    vim.api.nvim_set_option_value('buflisted', false, { buf = args.buf })
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

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dotenv',
  callback = function()
    vim.schedule(function()
      vim.bo.syntax = 'conf'
    end)
  end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()

    if vim.b[buf].ts_folds == nil then
      -- as long as we don't have a filetype, don't bother
      -- checking if treesitter is available (it won't)
      if vim.bo[buf].filetype == '' then
        return
      end

      if vim.bo[buf].filetype:find '\b(dashboard|bigfile)' then
        vim.b[buf].ts_folds = false
        vim.opt_local.foldmethod = 'manual'
      else
        vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)

        if vim.b[buf].ts_folds then
          vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.opt_local.foldmethod = 'expr'
        else
          vim.opt_local.foldmethod = 'syntax'
        end
      end
    end
  end,
})

return {}

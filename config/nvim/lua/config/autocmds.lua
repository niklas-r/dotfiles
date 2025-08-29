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
    vim.hl.on_yank()
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

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode, customOpts)
      mode = mode or 'n'
      local opts = vim.tbl_extend('force', { buffer = event.buf, desc = 'LSP: ' .. desc }, customOpts or {})
      vim.keymap.set(mode, keys, func, opts)
    end

    map('<leader>rn', function()
      return ':IncRename ' .. vim.fn.expand '<cword>'
    end, '[R]e[n]ame', 'n', { expr = true })
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Cursorline only in active window
local cl_var = 'auto_cursorline'

vim.api.nvim_create_autocmd({ 'WinEnter', 'FocusGained' }, {
  group = vim.api.nvim_create_augroup('enable_auto_cursorline', { clear = true }),
  callback = function()
    local ok, cl = pcall(vim.api.nvim_win_get_var, 0, cl_var)
    if ok and cl then
      vim.api.nvim_win_del_var(0, cl_var)
      vim.o.cursorline = true
    end
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'FocusLost' }, {
  group = vim.api.nvim_create_augroup('disable_auto_cursorline', { clear = true }),
  callback = function()
    local cl = vim.o.cursorline
    if cl then
      vim.api.nvim_win_set_var(0, cl_var, cl)
      vim.o.cursorline = false
    end
  end,
})

return {}

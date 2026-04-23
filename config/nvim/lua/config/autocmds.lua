local au = vim.api.nvim_create_autocmd

local _aug = function(name, opts)
  return vim.api.nvim_create_augroup(name .. 'Group', opts or {})
end

---@class Autogroups
---@field Cursor             number for cursor related autocommands.
---@field Lsp                number for LSP related autocommands.
---@field MacroRecording     number when a macro recording starts or ends.
---@field OnLazyFile         number when entering a file.
---@field OnVimHelpEnter     number when entering vim help files.
---@field OneKeyExit         number for exiting some views with a single key.
local aug = {
  Cursor = _aug('Cursor', { clear = true }),
  Lsp = _aug('Lsp', { clear = true }),
  MacroRecording = _aug 'MacroRecording',
  OnLazyFile = _aug 'OnLazyFile',
  OnVimHelpEnter = _aug 'OnVimHelpEnter',
  OneKeyExit = _aug 'OneKeyExit',
}

-- Don't add DAP buffers to list of buffers
au('FileType', {
  pattern = 'dap-repl',
  callback = function(args)
    vim.api.nvim_set_option_value('buflisted', false, { buf = args.buf })
  end,
})

-- Rename help buffer to just "help" and remap some keys
au('FileType', {
  desc = 'remap some keys for the help page',
  pattern = 'help',
  group = aug.OnVimHelpEnter,
  callback = function()
    local opts = function(desc)
      return { buffer = true, silent = true, desc = desc }
    end
    vim.keymap.set('n', '<CR>', '<C-]>', opts 'Jump to tag')
    vim.keymap.set('n', '<BS>', '<C-o>', opts 'Return to prev tag')
    vim.keymap.set('n', 'q', ':quit<CR>', opts 'exit help buffer')
    vim.opt_local.conceallevel = 3
    vim.opt_local.concealcursor = 'nvc'
  end,
})

---Quit from some windows by only pressing q
au('FileType', {
  desc = "Exit some views with 'q'",
  pattern = {
    'qf',
    'dap-float',
    'neotest-summary',
    'man',
  },
  command = [[nnoremap <buffer><silent> q :quit<CR>]],
  group = aug.OneKeyExit,
})

-- Highlight when yanking (copying) text
au('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = aug.Cursor,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Used to display recording in lualine
-- Autocmd to track the end of macro recording
au('RecordingEnter', {
  pattern = '*',
  group = aug.MacroRecording,
  callback = function()
    vim.g.macro_recording = 'Recording @' .. vim.fn.reg_recording()
    vim.cmd 'redrawstatus'
    require('lualine').refresh { force = true, placement = { 'statusline' } }
  end,
})

-- Autocmd to track the end of macro recording
au('RecordingLeave', {
  pattern = '*',
  group = aug.MacroRecording,
  callback = function()
    vim.g.macro_recording = ''
    vim.cmd 'redrawstatus'
    require('lualine').refresh { force = true, placement = { 'statusline' } }
  end,
})

au('FileType', {
  pattern = 'dotenv',
  group = aug.OnLazyFile,
  callback = function()
    vim.schedule(function()
      vim.bo.syntax = 'conf'
    end)
  end,
})

au('LspAttach', {
  group = aug.Lsp,
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
      local highlight_augroup = aug.Lsp
      au({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      au({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      au('LspDetach', {
        group = aug.Lsp,
        callback = function(event2)
          vim.lsp.buf.clear_references()
          pcall(vim.api.nvim_clear_autocmds, { group = 'lsp-highlight', buffer = event2.buf })
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

au({ 'WinEnter', 'FocusGained' }, {
  group = aug.Cursor,
  callback = function()
    local ok, cl = pcall(vim.api.nvim_win_get_var, 0, cl_var)
    if ok and cl then
      vim.api.nvim_win_del_var(0, cl_var)
      vim.o.cursorline = true
    end
  end,
})

au({ 'WinLeave', 'FocusLost' }, {
  group = aug.Cursor,
  callback = function()
    local cl = vim.o.cursorline
    if cl then
      vim.api.nvim_win_set_var(0, cl_var, cl)
      vim.o.cursorline = false
    end
  end,
})

return {}

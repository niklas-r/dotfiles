-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = 'ä'

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
-- I don't like this option but I'll keep it here in case I change my mind
-- vim.schedule(function()
--   vim.opt.clipboard = 'unnamedplus'
-- end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Use 2 spaces for indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false
vim.opt.listchars = { tab = '→ ', space = '·', trail = '•', nbsp = '␣', eol = '¶', precedes = '«', extends = '»' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'nosplit'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Enable 24-bit colour
vim.opt.termguicolors = true

vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]

-- Fold inspired by LazyVim
vim.opt.foldenable = true
vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}
vim.opt.foldcolumn = '1' -- '0' is not bad
vim.opt.foldlevel = 99
vim.opt.smoothscroll = true
vim.opt.foldmethod = 'indent'
-- Setting this will allow foldexpr (among others) to use more memory
vim.opt.maxmempattern = 2000000

local signs_config = {
  [vim.diagnostic.severity.ERROR] = { icon = '', hl = 'DiagnosticSignError' },
  [vim.diagnostic.severity.WARN] = { icon = '', hl = 'DiagnosticSignWarn' },
  [vim.diagnostic.severity.INFO] = { icon = '', hl = 'DiagnosticSignInfo' },
  [vim.diagnostic.severity.HINT] = { icon = '', hl = 'DiagnosticSignHint' },
}

local signs = { text = {}, texthl = {}, numhl = {} }
for severity, config in pairs(signs_config) do
  signs.text[severity] = config.icon
  signs.texthl[severity] = config.hl
  signs.numhl[severity] = config.hl
end

vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  signs = signs,
}

-- Use ripgrep for grepping
vim.opt.grepformat = '%f:%l:%c:%m'
vim.opt.grepprg = 'rg --vimgrep'

vim.o.conceallevel = 2
vim.o.concealcursor = 'nc'

vim.o.winborder = 'rounded'

return {}

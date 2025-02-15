--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
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

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Enable 24-bit colour which is required for vim-notify
vim.opt.termguicolors = true

-- Set default code folding to depend on Treesitter
vim.opt.foldenable = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- Optional
-- Show fold in side column
vim.opt.foldcolumn = '1' -- '0' is not bad
-- Folds with higher level than this will be closed with zm, zM, zR etc.
vim.opt.foldlevel = 99
-- Sets the foldlevel when starting to edit another buffer
vim.opt.foldlevelstart = 99
-- vim.opt.foldcolumn = 0
-- vim.opt.foldtext = ''

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', function()
  vim.cmd 'nohlsearch'
  if package.loaded['notify'] ~= nil then
    require('notify').dismiss { pending = true, silent = true }
  end
  if Snacks ~= nil then
    Snacks.notifier.hide()
  end
end)

vim.diagnostic.config { virtual_text = false, virtual_lines = false, float = { border = 'rounded' } }

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- Keys set with smart-splits instead
-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Don't add DAP buffers to list of buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dap-repl',
  callback = function(args)
    vim.api.nvim_set_option_value('buflisted', false, { buffer = args.buf })
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

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

local ai_whichkey = function(opts)
  local objects = {
    { ' ', desc = 'whitespace' },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { '(', desc = '() block' },
    { ')', desc = '() block with ws' },
    { '<', desc = '<> block' },
    { '>', desc = '<> block with ws' },
    { '?', desc = 'user prompt' },
    { 'U', desc = 'use/call without dot' },
    { '[', desc = '[] block' },
    { ']', desc = '[] block with ws' },
    { '_', desc = 'underscore' },
    { '`', desc = '` string' },
    { 'a', desc = 'argument' },
    { 'b', desc = ')]} block' },
    { 'c', desc = 'class' },
    { 'd', desc = 'digit(s)' },
    { 'e', desc = 'CamelCase / snake_case' },
    { 'm', desc = 'method' },
    { 'g', desc = 'entire file' },
    { 'i', desc = 'indent' },
    { 'o', desc = 'block, conditional, loop' },
    { 'q', desc = 'quote `"\'' },
    { 't', desc = 'tag' },
    { 'u', desc = 'use/call' },
    { '{', desc = '{} block' },
    { '}', desc = '{} with ws' },
  }

  local ret = { mode = { 'o', 'x' } }
  ---@type table<string, string>
  local mappings = vim.tbl_extend('force', {}, {
    around = 'a',
    inside = 'i',
    around_next = 'an',
    inside_next = 'in',
    around_last = 'al',
    inside_last = 'il',
  }, opts.mappings or {})
  mappings.goto_left = nil
  mappings.goto_right = nil

  for name, prefix in pairs(mappings) do
    name = name:gsub('^around_', ''):gsub('^inside_', '')
    ret[#ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      if prefix:sub(1, 1) == 'i' then
        desc = desc:gsub(' with ws', '')
      end
      ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
    end
  end
  require('which-key').add(ret, { notify = false })
end

-- Icons to use in the completion menu.
-- local symbol_kinds = {
--   Class = '',
--   Color = '',
--   Constant = '',
--   Constructor = '',
--   Copilot = '',
--   Enum = '',
--   EnumMember = '',
--   Event = '',
--   Field = '',
--   File = '',
--   Folder = '',
--   Function = '',
--   Interface = '',
--   Keyword = '',
--   Method = '',
--   Module = '',
--   Operator = '',
--   Property = '',
--   Reference = '',
--   Snippet = '',
--   Struct = '',
--   Text = '',
--   TypeParameter = '',
--   Unit = '',
--   Value = '',
--   Variable = '',
-- }

-- local has_words_before = function()
--   if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt' then
--     return false
--   end
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match '^%s*$' == nil
-- end

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup {
  checker = {
    enabled = true,
    notify = false, -- hide notification since it's displayed in the lualine
  },
  install = {
    colorscheme = { 'tokyonight' },
  },
  spec = {
    -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

    -- NOTE: Plugins can also be added by using a table,
    -- with the first argument being the link and the following
    -- keys can be used to configure plugin behavior/loading/etc.
    --
    -- Use `opts = {}` to force a plugin to be loaded.
    --

    -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
    --
    -- This is often very useful to both group configuration, as well as handle
    -- lazy loading plugins that don't need to be loaded immediately at startup.
    --
    -- For example, in the following configuration, we use:
    --  event = 'VimEnter'
    --
    -- which loads which-key before all the UI elements are loaded. Events can be
    -- normal autocommands events (`:help autocmd-events`).
    --
    -- Then, because we use the `config` key, the configuration only runs
    -- after the plugin has been loaded:
    --  config = function() ... end

    -- NOTE: Plugins can specify dependencies.
    --
    -- The dependencies are proper plugin specifications as well - anything
    -- you do for a plugin at the top level, you can do for a dependency.
    --
    -- Use the `dependencies` key to specify the dependencies of a particular plugin

    --   { -- Autocompletion
    --     'hrsh7th/nvim-cmp',
    --     version = false,
    --     event = 'InsertEnter',
    --     dependencies = {
    --       -- Snippet Engine & its associated nvim-cmp source
    --       {
    --         'L3MON4D3/LuaSnip',
    --         build = (function()
    --           -- Build Step is needed for regex support in snippets.
    --           -- This step is not supported in many windows environments.
    --           -- Remove the below condition to re-enable on windows.
    --           if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
    --             return
    --           end
    --           return 'make install_jsregexp'
    --         end)(),
    --         dependencies = {
    --           -- `friendly-snippets` contains a variety of premade snippets.
    --           --    See the README about individual language/framework/plugin snippets:
    --           --    https://github.com/rafamadriz/friendly-snippets
    --           -- {
    --           --   'rafamadriz/friendly-snippets',
    --           --   config = function()
    --           --     require('luasnip.loaders.from_vscode').lazy_load()
    --           --   end,
    --           -- },
    --         },
    --       },
    --       'saadparwaiz1/cmp_luasnip',
    --
    --       -- Adds other completion capabilities.
    --       --  nvim-cmp does not ship with all sources by default. They are split
    --       --  into multiple repos for maintenance purposes.
    --       'hrsh7th/cmp-nvim-lsp',
    --       'hrsh7th/cmp-path',
    --       -- copilot
    --       'zbirenbaum/copilot-cmp',
    --       'rcarriga/cmp-dap',
    --       -- Needed to display Tailwind colors in auto-completion
    --       'tailwind-tools',
    --       'onsails/lspkind-nvim',
    --     },
    --     config = function()
    --       -- See `:help cmp`
    --       local cmp = require 'cmp'
    --       local luasnip = require 'luasnip'
    --       luasnip.config.setup {}
    --
    --       cmp.setup {
    --         enabled = function()
    --           return vim.api.nvim_get_option_value('buftype', {}) ~= 'prompt' or require('cmp_dap').is_dap_buffer()
    --         end,
    --         -- Disable preselect. On enter, the first thing will be used if nothing
    --         -- is selected.
    --         preselect = cmp.PreselectMode.None,
    --         -- Add icons to the completion menu.
    --         formatting = {
    --           format = function(entry, vim_item)
    --             local lspkind_ok, lspkind = pcall(require, 'lspkind')
    --
    --             -- Add nice icons :)
    --             vim_item.kind = (symbol_kinds[vim_item.kind] or '') .. '  ' .. vim_item.kind
    --
    --             if lspkind_ok then
    --               return lspkind.cmp_format {
    --                 -- Add colors to Tailwind color completions
    --                 before = require('tailwind-tools.cmp').lspkind_format,
    --               }(entry, vim_item)
    --             end
    --
    --             return vim_item
    --           end,
    --         },
    --         snippet = {
    --           expand = function(args)
    --             luasnip.lsp_expand(args.body)
    --           end,
    --         },
    --         window = {
    --           -- Make the completion menu bordered.
    --           completion = cmp.config.window.bordered(),
    --           documentation = cmp.config.window.bordered(),
    --         },
    --         view = {
    --           -- Explicitly request documentation.
    --           docs = { auto_open = false },
    --         },
    --         completion = { completeopt = 'menu,menuone,noselect' },
    --
    --         -- For an understanding of why these mappings were
    --         -- chosen, you will need to read `:help ins-completion`
    --         --
    --         -- No, but seriously. Please read `:help ins-completion`, it is really good!
    --         mapping = cmp.mapping.preset.insert {
    --           -- Select the [n]ext item
    --           ['<C-n>'] = cmp.mapping.select_next_item(),
    --           -- Select the [p]revious item
    --           ['<C-p>'] = cmp.mapping.select_prev_item(),
    --
    --           -- Scroll the documentation window [b]ack / [f]orward
    --           ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    --           ['<C-f>'] = cmp.mapping.scroll_docs(4),
    --
    --           -- Accept ([y]es) the completion.
    --           --  This will auto-import if your LSP supports it.
    --           --  This will expand snippets if the LSP sent a snippet.
    --           ['<C-y>'] = cmp.mapping.confirm { select = true },
    --
    --           -- If you prefer more traditional completion keymaps,
    --           -- you can uncomment the following lines
    --           ['<CR>'] = cmp.mapping.confirm { select = false },
    --
    --           ['<Tab>'] = cmp.mapping(function(fallback)
    --             if cmp.visible() then
    --               cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
    --             else
    --               fallback()
    --             end
    --           end),
    --           -- ['<Tab>'] = vim.schedule_wrap(function(fallback)
    --           --   if cmp.visible() and has_words_before() then
    --           --     cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
    --           --   else
    --           --     fallback()
    --           --   end
    --           -- end),
    --           ['<S-Tab>'] = cmp.mapping(function(fallback)
    --             if cmp.visible() then
    --               cmp.select_prev_item()
    --             elseif luasnip.expand_or_locally_jumpable(-1) then
    --               luasnip.jump(-1)
    --             else
    --               fallback()
    --             end
    --           end, { 'i', 's' }),
    --           -- Open docs manually, useful for Copilot completions
    --           ['<C-d>'] = function()
    --             if cmp.visible_docs() then
    --               cmp.close_docs()
    --             else
    --               cmp.open_docs()
    --             end
    --           end,
    --
    --           -- Manually trigger a completion from nvim-cmp.
    --           --  Generally you don't need this, because nvim-cmp will display
    --           --  completions whenever it has completion options available.
    --           ['<C-Space>'] = cmp.mapping.complete {},
    --
    --           -- Think of <c-l> as moving to the right of your snippet expansion.
    --           --  So if you have a snippet that's like:
    --           --  function $name($args)
    --           --    $body
    --           --  end
    --           --
    --           -- <c-l> will move you to the right of each of the expansion locations.
    --           -- <c-h> is similar, except moving you backwards.
    --           ['<C-l>'] = cmp.mapping(function()
    --             if luasnip.expand_or_locally_jumpable() then
    --               luasnip.expand_or_jump()
    --             end
    --           end, { 'i', 's' }),
    --           ['<C-h>'] = cmp.mapping(function()
    --             if luasnip.locally_jumpable(-1) then
    --               luasnip.jump(-1)
    --             end
    --           end, { 'i', 's' }),
    --
    --           -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --           --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    --         },
    --         sorting = {
    --           priority_weight = 2,
    --           comparators = {
    --             require('copilot_cmp.comparators').prioritize,
    --             cmp.config.compare.kind,
    --             cmp.config.compare.offset,
    --             cmp.config.compare.exact,
    --             cmp.config.compare.score,
    --             cmp.config.compare.recently_used,
    --             cmp.config.compare.scopes,
    --             cmp.config.compare.locality,
    --             cmp.config.compare.sort_text,
    --             cmp.config.compare.length,
    --             cmp.config.compare.order,
    --           },
    --         },
    --         sources = cmp.config.sources {
    --           {
    --             name = 'lazydev',
    --             -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
    --             group_index = 0,
    --           },
    --           { name = 'copilot' },
    --           { name = 'nvim_lsp' },
    --           { name = 'luasnip' },
    --           { name = 'snippets', keyword_length = 3 },
    --           { name = 'path' },
    --           { { name = 'buffer' } },
    --           {},
    --         },
    --       }
    --
    --       -- cmp.setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
    --       cmp.setup.filetype({ 'dap-repl', 'dapui_watches' }, {
    --         sources = {
    --           { name = 'dap' },
    --         },
    --       })
    --     end,
    --   },

    -- Highlight todo, notes, etc in comments
    { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

    { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      event = 'VeryLazy',

      config = function()
        local ai = require 'mini.ai'
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        local ai_opts = {
          n_liness = 500,
          custom_textobjects = {
            o = ai.gen_spec.treesitter { -- code block
              a = { '@block.outer', '@conditional.outer', '@loop.outer' },
              i = { '@block.inner', '@conditional.inner', '@loop.inner' },
            },
            m = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' }, -- method/function
            c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' }, -- class
            t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
            d = { '%f[%d]%d+' }, -- digits
            e = { -- Word with case
              { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
              '^().*()$',
            },
            u = ai.gen_spec.function_call(), -- u for "Usage"
            U = ai.gen_spec.function_call { name_pattern = '[%w_]' }, -- without dot in function name
          },
        }

        ai.setup(ai_opts)
        ai_whichkey(ai_opts)

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - gsaiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - gsd'   - [S]urround [D]elete [']quotes
        -- - gsr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup {
          -- Module mappings. Use `''` (empty string) to disable one.
          mappings = {
            add = 'gsa', -- Add surrounding in Normal and Visual modes
            delete = 'gsd', -- Delete surrounding
            find = 'gsf', -- Find surrounding (to the right)
            find_left = 'gsF', -- Find surrounding (to the left)
            highlight = 'gsh', -- Highlight surrounding
            replace = 'gsr', -- Replace surrounding
            update_n_lines = 'gsn', -- Update `n_lines`

            suffix_last = 'l', -- Suffix to search with "prev" method
            suffix_next = 'n', -- Suffix to search with "next" method
          },
        }

        -- Simple and easy statusline.
        --  You could remove this setup call if you don't like it,
        --  and try some other statusline plugin
        -- local statusline = require 'mini.statusline'
        -- statusline.setup {
        --   -- set use_icons to true if you have a Nerd Font
        --   use_icons = vim.g.have_nerd_font,
        --   content = {
        --     active = function()
        --       local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
        --       local git = statusline.section_git { trunc_width = 40 }
        --       local diff = statusline.section_diff { trunc_width = 75 }
        --       local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
        --       local lsp = statusline.section_lsp { trunc_width = 75 }
        --       local filename = statusline.section_filename { trunc_width = 140 }
        --       local fileinfo = statusline.section_fileinfo { trunc_width = 120 }
        --       local search = statusline.section_searchcount { trunc_width = 75 }
        --       local macro = vim.g.macro_recording
        --
        --       return MiniStatusline.combine_groups {
        --         { hl = mode_hl, strings = { mode } },
        --         { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
        --         { hl = '', strings = { '%<' } }, -- Mark general truncate point
        --         '%=', -- End left alignment, start center alignment
        --         { hl = 'MiniStatuslineFilename', strings = { filename } },
        --         '%=', -- End center alignment, start right alignment
        --         { hl = 'MiniStatuslineFilename', strings = { macro } },
        --         { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        --         { hl = mode_hl, strings = { search, '%2l:%-2v' } },
        --       }
        --     end,
        --   },
        -- }
        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim
      end,
    },
    { -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      event = { 'BufReadPre', 'BufNewFile' },
      main = 'nvim-treesitter.configs', -- Sets main module to use for opts
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
      dependencies = {
        'nvim-treesitter/nvim-treesitter-context',
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      opts = {
        ensure_installed = {
          'json',
          'yaml',
          'javascript',
          'typescript',
          'bash',
          'c',
          'diff',
          'html',
          'lua',
          'luadoc',
          'markdown',
          'markdown_inline',
          'query',
          'vim',
          'vimdoc',
          'gitignore',
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'ruby' },
        },
        incremental_selection = {
          -- FIXME: Disabled this because it breaks <C-i> for some reason
          enable = false,
          keymaps = {
            init_selection = '<Tab>',
            node_incremental = '<Tab>',
            scope_incremental = false,
            node_decremental = '<S-Tab>',
          },
        },
        indent = { enable = true, disable = { 'ruby' } },
        textobjects = {
          lsp_interop = {
            enable = true,
            border = 'none',
            floating_preview_opts = { border = 'rounded' },
          },
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            -- Extra mappings that can be used with mini.surround and mini.ai
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['am'] = { query = '@function.outer', desc = 'around method' },
              ['im'] = { query = '@function.inner', desc = 'in method' },
              ['ac'] = { query = '@class.outer', desc = 'around class' },
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ['ic'] = { query = '@class.inner', desc = 'in class' },
              -- You can also use captures from other query groups like `locals.scm`
              ['as'] = { query = '@local.scope', query_group = 'locals', desc = 'around scope' },
            },

            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ['@parameter.outer'] = 'v',
              ['@function.outer'] = 'V',
              ['@class.outer'] = 'V',
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true or false
            include_surrounding_whitespace = true,
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>Sp'] = { query = '@parameter.inner', desc = '[S]wap with next [P]arameter' },
              ['<leader>Sm'] = { query = '@function.outer', desc = '[S]wap with next [M]ethod' },
            },
            swap_previous = {
              ['<leader>SP'] = { query = '@parameter.inner', desc = '[S]wap with prev [P]arameter' },
              ['<leader>SM'] = { query = '@function.outer', desc = '[S]wap with prev [M]ethod' },
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = { query = '@function.outer', desc = 'Next [M]ethod' },
              [']c'] = { query = '@class.outer', desc = 'Next [C]lass' },
              --
              -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
              [']o'] = { query = '@loop.*', desc = 'Next L[o]op' },
              -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
              --
              -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
              -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
              [']s'] = { query = '@local.scope', query_group = 'locals', desc = 'Next [S]cope' },
              [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next [F]old' },
            },
            goto_next_end = {
              [']M'] = { query = '@function.outer', desc = 'Next [M]ethod end' },
              [']C'] = { query = '@class.outer', desc = 'Next [C]lass end' },
            },
            goto_previous_start = {
              ['[m'] = { query = '@function.outer', desc = 'Prev [M]ethod' },
              ['[c'] = { query = '@class.outer', desc = 'Prev [C]lass' },
            },
            goto_previous_end = {
              ['[M'] = { query = '@function.outer', desc = 'Prev [M]ethod end' },
              ['[C'] = { query = '@class.outer', desc = 'Prev [C]lass end' },
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
              [']n'] = { query = '@conditional.outer', desc = 'Next co[N]dition' },
            },
            goto_previous = {
              ['[n'] = { query = '@conditional.outer', desc = 'Prev co[N]dition' },
            },
          },
        },
      },
      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    },

    -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
    -- init.lua. If you want these files, they are in the repository, so you can just download them and
    -- place them in the correct locations.

    -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
    --
    --  Here are some example plugins that I've included in the Kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    { import = 'plugins' },
    -- Custom config lua files
    require 'config.filetypes',
    require 'config.focus-split',
    require 'config.remaps',
    require 'config.autocmds',
    -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
    -- Or use telescope!
    -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
    -- you can continue same window with `<space>sr` which resumes last telescope search
  },
  {
    ui = {
      -- If you are using a Nerd Font: set icons to an empty table which will use the
      -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
      icons = vim.g.have_nerd_font and {} or {
        cmd = '⌘',
        config = '🛠',
        event = '📅',
        ft = '📂',
        init = '⚙',
        keys = '🗝',
        plugin = '🔌',
        runtime = '💻',
        require = '🌙',
        source = '📄',
        start = '🚀',
        task = '📌',
        lazy = '💤 ',
      },
    },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

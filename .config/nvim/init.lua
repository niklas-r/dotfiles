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
  if require 'snacks' ~= nil then
    require('snacks').notifier.hide()
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

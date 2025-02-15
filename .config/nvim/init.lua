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
local symbol_kinds = {
  Class = '',
  Color = '',
  Constant = '',
  Constructor = '',
  Copilot = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = '',
  File = '',
  Folder = '',
  Function = '',
  Interface = '',
  Keyword = '',
  Method = '',
  Module = '',
  Operator = '',
  Property = '',
  Reference = '',
  Snippet = '',
  Struct = '',
  Text = '',
  TypeParameter = '',
  Unit = '',
  Value = '',
  Variable = '',
}

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

    -- Here is a more advanced example where we pass configuration
    -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
    --    require('gitsigns').setup({ ... })
    --
    -- See `:help gitsigns` to understand what the configuration keys do
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
      'lewis6991/gitsigns.nvim',
      opts = {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      },
    },

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

    { -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VimEnter', -- Sets the loading event to 'VimEnter'
      keys = {
        {
          '<leader>?',
          function()
            require('which-key').show { global = false }
          end,
          desc = 'Buffer Local Keymaps (which-key)',
        },
        {
          '<leader>t',
          function()
            -- Show hydra mode for toggles
            require('which-key').show {
              keys = '<leader>t',
              loop = true, -- this will keep the popup open until you hit <esc>
            }
          end,
          desc = '[T]oggles',
        },
      },
      opts = {
        icons = {
          -- set icon mappings to true if you have a Nerd Font
          mappings = vim.g.have_nerd_font,
          -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
          -- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
          keys = vim.g.have_nerd_font and {} or {
            Up = '<Up> ',
            Down = '<Down> ',
            Left = '<Left> ',
            Right = '<Right> ',
            C = '<C-…> ',
            M = '<M-…> ',
            D = '<D-…> ',
            S = '<S-…> ',
            CR = '<CR> ',
            Esc = '<Esc> ',
            ScrollWheelDown = '<ScrollWheelDown> ',
            ScrollWheelUp = '<ScrollWheelUp> ',
            NL = '<NL> ',
            BS = '<BS> ',
            Space = '<Space> ',
            Tab = '<Tab> ',
            F1 = '<F1>',
            F2 = '<F2>',
            F3 = '<F3>',
            F4 = '<F4>',
            F5 = '<F5>',
            F6 = '<F6>',
            F7 = '<F7>',
            F8 = '<F8>',
            F9 = '<F9>',
            F10 = '<F10>',
            F11 = '<F11>',
            F12 = '<F12>',
          },
        },

        preset = 'modern',

        -- Document existing key chains
        spec = {
          { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
          { '<leader>d', group = '[D]ocument' },
          { '<leader>r', group = '[R]ename' },
          { '<leader>s', group = '[S]earch' },
          { '<leader>w', group = '[W]orkspace' },
          { '<leader>m', group = 'Harpoon [M]arks', mode = { 'n' } },
          { '<leader>u', group = '[U]nit Test', mode = { 'n' } },
          { '<leader>ud', group = '[U]nit Test [D]ebug', mode = { 'n' } },
          { '<leader>ur', group = '[U]nit Test [R]un', mode = { 'n' } },
          { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
          { '<leader>x', group = '[X] Trouble' },
          { '<leader>gp', group = '[G]oto [P]review' },
          { '<leader>S', group = '[S]wap' },
          { '<leader>g', group = '[G]lance' },
          { '<leader>l', group = '[L]azygit' },
          { '<leader>a', group = '[A]I' },
        },
      },
    },

    -- NOTE: Plugins can specify dependencies.
    --
    -- The dependencies are proper plugin specifications as well - anything
    -- you do for a plugin at the top level, you can do for a dependency.
    --
    -- Use the `dependencies` key to specify the dependencies of a particular plugin

    { -- Fuzzy Finder (files, lsp, etc)
      'nvim-telescope/telescope.nvim',
      event = 'VimEnter',
      branch = '0.1.x',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { -- If encountering errors, see telescope-fzf-native README for installation instructions
          'nvim-telescope/telescope-fzf-native.nvim',

          -- `build` is used to run some command when the plugin is installed/updated.
          -- This is only run then, not every time Neovim starts up.
          build = 'make',

          -- `cond` is a condition used to determine whether this plugin should be
          -- installed and loaded.
          cond = function()
            return vim.fn.executable 'make' == 1
          end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },

        -- Useful for getting pretty icons, but requires a Nerd Font.
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
        'folke/trouble.nvim',
      },
      config = function()
        -- Telescope is a fuzzy finder that comes with a lot of different things that
        -- it can fuzzy find! It's more than just a "file finder", it can search
        -- many different aspects of Neovim, your workspace, LSP, and more!
        --
        -- The easiest way to use Telescope, is to start by doing something like:
        --  :Telescope help_tags
        --
        -- After running this command, a window will open up and you're able to
        -- type in the prompt window. You'll see a list of `help_tags` options and
        -- a corresponding preview of the help.
        --
        -- Two important keymaps to use while in Telescope are:
        --  - Insert mode: <c-/>
        --  - Normal mode: ?
        --
        -- This opens a window that shows you all of the keymaps for the current
        -- Telescope picker. This is really useful to discover what Telescope can
        -- do as well as how to actually do it!

        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`
        local open_with_trouble = require('trouble.sources.telescope').open

        -- Use this to add more results without clearing the trouble list
        local add_to_trouble = require('trouble.sources.telescope').add

        local fzf_opts = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = 'smart_case', -- or "ignore_case" or "respect_case" the default case_mode is "smart_case"
        }

        require('telescope').setup {
          -- You can put your default mappings / updates / etc. in here
          --  All the info you're looking for is in `:help telescope.setup()`
          --
          pickers = {
            find_files = {
              hidden = true,
            },
            buffer = {
              mappings = {
                i = {
                  ['<C-d>'] = 'delete_buffer',
                },
                n = {
                  ['<C-d>'] = 'delete_buffer',
                },
              },
            },
            -- Manually set sorter, for some reason not picked up automatically
            lsp_dynamic_workspace_symbols = {
              sorter = require('telescope').extensions.fzf.native_fzf_sorter(fzf_opts),
            },
          },
          defaults = {
            mappings = {
              i = {
                -- FIXME: which_key doesn't get updated with custom keybinds
                ['<C-7>'] = 'which_key',
                ['<C-x>'] = open_with_trouble,
                ['<C-X>'] = add_to_trouble,
                ['<C-t>'] = 'file_tab',
                ['<C-s>'] = 'select_horizontal',
              },
              n = {
                ['<C-x>'] = open_with_trouble,
                ['<C-X>'] = add_to_trouble,
                ['<C-t>'] = 'file_tab',
                ['<C-s>'] = 'select_horizontal',
              },
            },
            file_ignore_patterns = {
              '^.git/',
              '^node_modules/',
              '^build/',
              '^coverage/',
              '%.lock',
              '%.snap',
            },
            vimgrep_arguments = {
              'rg',
              '--color=never',
              '--no-heading',
              '--with-filename',
              '--line-number',
              '--column',
              '--smart-case',
              '--hidden',
              '--ignore-file',
              '.gitignore',
            },
          },
          -- pickers = {}
          extensions = {
            ['ui-select'] = {
              require('telescope.themes').get_dropdown(),
            },
            extensions = {
              fzf = fzf_opts,
            },
          },
        }

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        -- See `:help telescope.builtin`
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
        -- vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sg', require('custom.config.telescope').live_multigrep, { desc = '[S]earch by Multi[G]rep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

        -- Slightly advanced example of overriding default behavior and theme
        vim.keymap.set('n', '<leader>/', function()
          -- You can pass additional configuration to Telescope to change the theme, layout, etc.
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end, { desc = '[/] Fuzzily search in current buffer' })

        -- It's also possible to pass additional configuration options.
        --  See `:help telescope.builtin.live_grep()` for information about particular keys
        vim.keymap.set('n', '<leader>s/', function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end, { desc = '[S]earch [/] in Open Files' })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>sn', function()
          builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = '[S]earch [N]eovim files' })
      end,
    },

    -- LSP Plugins
    {
      -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = 'luvit-meta/library', words = { 'vim%.uv' } },
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
    { 'Bilal2453/luvit-meta', lazy = true },
    {
      -- Main LSP Configuration
      'neovim/nvim-lspconfig',
      dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Useful status updates for LSP.
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { 'j-hui/fidget.nvim', opts = {} },

        -- Allows extra capabilities provided by nvim-cmp
        -- 'hrsh7th/cmp-nvim-lsp',
        -- Allows extra capabilities provided by blink-cmp
        'saghen/blink.cmp',
        'dmmulroy/ts-error-translator.nvim',
      },
      config = function()
        -- Brief aside: **What is LSP?**
        --
        -- LSP is an initialism you've probably heard, but might not understand what it is.
        --
        -- LSP stands for Language Server Protocol. It's a protocol that helps editors
        -- and language tooling communicate in a standardized fashion.
        --
        -- In general, you have a "server" which is some tool built to understand a particular
        -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
        -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
        -- processes that communicate with some "client" - in this case, Neovim!
        --
        -- LSP provides Neovim with features like:
        --  - Go to definition
        --  - Find references
        --  - Autocompletion
        --  - Symbol Search
        --  - and more!
        --
        -- Thus, Language Servers are external tools that must be installed separately from
        -- Neovim. This is where `mason` and related plugins come into play.
        --
        -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
        -- and elegantly composed help section, `:help lsp-vs-treesitter`

        --  This function gets run when an LSP attaches to a particular buffer.
        --    That is to say, every time a new file is opened that is associated with
        --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
        --    function will be executed to configure the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
          callback = function(event)
            -- NOTE: Remember that Lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc, mode, customOpts)
              mode = mode or 'n'
              local opts = vim.tbl_extend('force', { buffer = event.buf, desc = 'LSP: ' .. desc }, customOpts or {})
              vim.keymap.set(mode, keys, func, opts)
            end

            -- Jump to the definition of the word under your cursor.
            --  This is where a variable was first declared, or where a function is defined, etc.
            --  To jump back, press <C-t>.
            map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

            -- Find references for the word under your cursor.
            map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

            -- Jump to the implementation of the word under your cursor.
            --  Useful when your language has ways of declaring types without an actual implementation.
            map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

            -- Fuzzy find all the incoming and outgoing calls of a method
            map('gC', require('telescope.builtin').lsp_incoming_calls, '[G]oto Incoming [C]alls')
            map('gO', require('telescope.builtin').lsp_outgoing_calls, '[G]oto [O]utgoing Calls')

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

            -- Fuzzy find all the symbols in your current workspace.
            --  Similar to document symbols, except searches over your entire project.
            map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

            -- Rename the variable under your cursor.
            --  Most Language Servers support renaming across files, etc.
            --  Using inc-rename for a nicer popup with prefilled value
            map('<leader>rn', function()
              return ':IncRename ' .. vim.fn.expand '<cword>'
            end, '[R]e[n]ame', 'n', { expr = true })

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header.
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
              local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
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
                group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                callback = function(event2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                end,
              })
            end

            -- I don't understand how to use the LSP Code Lens at the moment,
            -- might be useful in the future so I'm keeping it
            -- if client and client.server_capabilities.codeLensProvider then
            --   vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
            --     callback = function()
            --       vim.lsp.codelens.refresh()
            --     end,
            --   })
            --   vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run, { desc = '[C]ode [L]ens', buffer = event.buf, silent = true })
            -- end

            -- The following code creates a keymap to toggle inlay hints in your
            -- code, if the language server you are using supports them
            --
            -- This may be unwanted, since they displace some of your code
            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
              map('<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
              end, '[T]oggle Inlay [H]ints')
            end
          end,
        })

        -- Change diagnostic symbols in the sign column (gutter)
        if vim.g.have_nerd_font then
          local signs = { Error = '', Warn = '', Hint = '', Info = '' }
          for type, icon in pairs(signs) do
            local hl = 'DiagnosticSign' .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
          end
        end

        -- LSP servers and clients are able to communicate to each other what features they support.
        --  By default, Neovim doesn't support everything that is in the LSP specification.
        --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        -- Enable the following language servers
        --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        --  Add any additional override configuration in the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local servers = {
          -- clangd = {},
          -- gopls = {},
          -- pyright = {},
          -- rust_analyzer = {},
          -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
          --
          -- Some languages (like typescript) have entire language plugins that can be useful:
          --    https://github.com/pmizio/typescript-tools.nvim
          --
          -- But for many setups, the LSP (`ts_ls`) will work just fine
          -- ts_ls = {},
          vtsls = {},
          eslint = {},
          jsonls = {
            settings = {
              json = {
                schemas = {
                  {
                    fileMatch = { 'package.json' },
                    url = 'https://json.schemastore.org/package.json',
                  },
                },
              },
            },
          },
          --
          bashls = {},

          lua_ls = {
            -- cmd = {...},
            -- filetypes = { ...},
            -- capabilities = {},
            settings = {
              Lua = {
                completion = {
                  callSnippet = 'Replace',
                },
                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                diagnostics = { disable = { 'missing-fields' } },
              },
            },
          },
        }

        -- Ensure the servers and tools above are installed
        --  To check the current status of installed tools and/or manually install
        --  other tools, you can run
        --    :Mason
        --
        --  You can press `g?` for help in this menu.
        require('mason').setup()

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
          'stylua', -- Used to format Lua code
          -- 'prettierd', -- Until this bug is solved I can't use it https://github.com/fsouza/prettierd/issues/352
          'prettier',
          'beautysh', -- Bash, Zsh etc formatter
          'jq', -- Fast JSON formatter and more
          'jsonlint',
          'yamllint',
          -- DAP's
          -- 'js-debug-adapter', -- js-debug-adapter needs to be installed with Lazy so we can run post-install scripts so it works with nvim-dap-vscode-js
          'chrome-debug-adapter',
        })
        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        require('mason-lspconfig').setup {
          handlers = {
            function(server_name)
              local server = servers[server_name] or {}
              -- This handles overriding only values explicitly passed
              -- by the server configuration above. Useful when disabling
              -- certain features of an LSP (for example, turning off formatting for ts_ls)
              server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

              -- Powers up the LSP capabilities with the blink-cmp autocompletion
              server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities)

              require('lspconfig')[server_name].setup(server)
            end,
          },
        }
      end,
    },

    { -- Autoformat
      'stevearc/conform.nvim',
      event = { 'BufWritePre' },
      cmd = { 'ConformInfo' },
      keys = {
        {
          '<leader>f',
          function()
            require('conform').format { async = true, lsp_format = 'fallback' }
          end,
          mode = '',
          desc = '[F]ormat buffer',
        },
      },
      opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true, json = true, yml = true }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = 'never'
          else
            lsp_format_opt = 'fallback'
          end
          return {
            timeout_ms = 500,
            lsp_format = lsp_format_opt,
          }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          -- Conform can also run multiple formatters sequentially
          -- python = { "isort", "black" },
          --
          -- You can use 'stop_after_first' to run the first available formatter from the list
          javascript = {
            --'prettierd',
            'prettier',
            stop_after_first = true,
          },
          typescript = {
            --'prettierd',
            'prettier',
            stop_after_first = true,
          },
          javascriptreact = {
            -- 'prettierd',
            'prettier',
            stop_after_first = true,
          },
          typescriptreact = {
            -- 'prettierd',
            'prettier',
            stop_after_first = true,
          },
          sh = { 'beautysh' },
          zsh = { 'beautysh' },
          json = { 'jq' },
        },
      },
    },

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

    -- Current color scheme is being set by colorscheme-persist
    -- Remember to add the color scheme to colorscheme-persist dependencies
    { 'catppuccin/nvim', priority = 1000 },
    { 'folke/tokyonight.nvim', priority = 1000 },
    { 'rebelot/kanagawa.nvim', priority = 1000 },
    { 'shatur/neovim-ayu', priority = 1000 },

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
    --
    require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    require 'kickstart.plugins.lint',
    require 'kickstart.plugins.autopairs',
    require 'kickstart.plugins.neo-tree',
    require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    { import = 'custom.plugins' },
    -- Custom config lua files
    require 'custom.config.filetypes',
    require 'custom.config.focus-split',
    require 'custom.config.remaps',
    require 'custom.config.autocmds',
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

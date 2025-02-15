require 'config/opts'

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

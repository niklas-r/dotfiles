return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  depenencies = {
    'folke/which-key.nvim',
  },
  keys = {
    -- stylua: ignore start
    { '<leader>!',  function() Snacks.dashboard.open() end, desc = 'Open Dashboard[!]', },
    { '<leader>n',  function() Snacks.notifier.show_history() end,     desc = '[N]otification History', },
    { '<leader>lh', function() Snacks.lazygit.log_file() end,          desc = '[L]azygit Current File [H]istory', },
    { '<leader>lg', function() Snacks.lazygit() end,                   desc = '[L]azy[g]it', },
    { '<leader>ll', function() Snacks.lazygit.log() end,               desc = '[L]azygit [L]og (cwd)', },
    { "<leader>rf", function() Snacks.rename.rename_file() end,        desc = "LSP: [R]ename [F]ile" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end,    desc = "Next Reference",                   mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end,   desc = "Prev Reference",                   mode = { "n", "t" } },
    -- stylua: ignore end
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>ts'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>tw'
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>tr'
        Snacks.toggle.diagnostics():map '<leader>td'
        Snacks.toggle.line_number():map '<leader>tl'
        Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>tc'
        Snacks.toggle.treesitter():map '<leader>tT'
        Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>tb'
        Snacks.toggle.inlay_hints():map '<leader>th'
        Snacks.toggle.indent():map '<leader>tg'
        Snacks.toggle.dim():map '<leader>tD'
        Snacks.toggle.zen():map '<leader>tz'
        Snacks.toggle.zoom():map '<leader>tZ'
        Snacks.toggle({
          name = 'LSP Lines',
          get = function()
            return vim.diagnostic.config().virtual_lines
          end,
          set = function()
            require('lsp_lines').toggle()
          end,
        }):map '<leader>tL'
      end,
    })
  end,
  opts = {
    bigfile = {
      enabled = true,
      notify = true, -- show notification when big file detected
      size = 1.5 * 1024 * 1024, -- 1.5MB
      -- Enable or disable features when big file detected
      ---@param ctx {buf: number, ft:string}
      setup = function(ctx)
        vim.b.minianimate_disable = true
        vim.schedule(function()
          vim.bo[ctx.buf].syntax = ctx.ft
        end)
      end,
    },
    lazygit = { enabled = true },
    notifier = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    toggle = {},
    indent = {
      enabled = true,
      animate = {
        enabled = false,
      },
      scope = {
        enabled = true,
      },
    },
    dashboard = {
      width = 60,
      row = nil, -- dashboard position. nil for center
      col = nil, -- dashboard position. nil for center
      pane_gap = 4, -- empty columns between vertical panes
      autokeys = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', -- autokey sequence
      -- These settings are used by some built-in sections
      preset = {
        -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
        ---@type fun(cmd:string, opts:table)|nil
        pick = nil,
        -- Used by the `keys` section to show keymaps.
        -- Set your custom keymaps here.
        -- When using a function, the `items` argument are the default keymaps.
        keys = {
          { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
          { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
          {
            icon = '󰒲 ',
            key = 'L',
            desc = 'Lazy',
            action = ':Lazy',
            enabled = package.loaded.lazy ~= nil,
          },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
        -- Used by the `header` section
        -- stylua: ignore start
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        -- stylua: ignore end
      },
      -- item field formatters
      formats = {
        icon = function(item)
          local snacks = require 'snacks'
          if item.file and item.icon == 'file' or item.icon == 'directory' then
            return snacks.dashboard.icon(item.file, item.icon)
          end
          return { item.icon, width = 2, hl = 'icon' }
        end,
        footer = { '%s', align = 'center' },
        header = { '%s', align = 'center' },
        file = function(item, ctx)
          local fname = vim.fn.fnamemodify(item.file, ':~')
          fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
          local dir, file = fname:match '^(.*)/(.+)$'
          return dir and { { dir .. '/', hl = 'dir' }, { file, hl = 'file' } } or { { fname, hl = 'file' } }
        end,
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = { 2, 2 } },
        { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 2 },
        { section = 'startup' },
      },
    },
  },
}

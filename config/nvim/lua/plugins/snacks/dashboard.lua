return {
  'folke/snacks.nvim',
  priority = 1000,
  keys = {
    {
      '<leader>!',
      function()
        Snacks.dashboard.open()
      end,
      desc = 'Open Dashboard[!]',
    },
  },
  opts = {
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
          -- stylua: ignore start
          header = [[ 
                                                                       
                                                                     
       ████ ██████           █████      ██                     
      ███████████             █████                             
      █████████ ███████████████████ ███   ███████████   
     █████████  ███    █████████████ █████ ██████████████   
    █████████ ██████████ █████████ █████ █████ ████ █████   
  ███████████ ███    ███ █████████ █████ █████ ████ █████  
 ██████  █████████████████████ ████ █████ █████ ████ ██████ 
                                                                       
          ]],
        -- stylua: ignore end
      },
      -- item field formatters
      formats = {
        icon = function(item)
          if item.file and item.icon == 'file' or item.icon == 'directory' then
            return Snacks.dashboard.icon(item.file, item.icon)
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
        {
          align = 'center',
          padding = 1,
          text = {
            { '  New ', hl = 'DiagnosticInfo' },
            { '  Files ', hl = '@constant' },
            { '  Grep ', hl = '@character' },
            { '  Recent ', hl = '@keyword.return' },
            { ' 󰒲 Lazy ', hl = '@label' },
            { '  Last Session ', hl = '@variable.parameter' },
            { '  Quit ', hl = '@comment' },
          },
        },
        { section = 'startup', padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = { 2, 2 } },
        { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 2 },
        --- Actions mapped to text section above
        -- Files
        {
          text = '',
          action = ":lua Snacks.dashboard.pick('files', { matcher = { frecency = true }, hidden = true, layout = { preset = 'vscode' } })",
          key = 'f',
        },
        -- New file
        { text = '', action = ':ene | startinsert', key = 'n' },
        -- Grep
        { text = '', action = ":lua Snacks.dashboard.pick('live_grep', { hidden = true })", key = 'g' },
        -- Recent files
        { text = '', action = ":lua Snacks.dashboard.pick('oldfiles', { hidden = true })", key = 'r' },
        { text = '', action = ':Lazy', key = 'l' },
        { text = '', section = 'session', key = 's' },
        { text = '', action = ':qa', key = 'q' },
      },
    },
  },
}

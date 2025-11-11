local function toggleColumnInfo()
  if vim.g.oil_columns == 4 then
    vim.g.oil_columns = 1
  else
    vim.g.oil_columns = vim.g.oil_columns + 1
  end

  ---@module 'oil'
  ---@type oil.ColumnSpec[]
  local selectedCols = { 'icon' } -- Always show icon

  if vim.g.oil_columns == 1 then
    selectedCols = { 'icon' }
  elseif vim.g.oil_columns == 2 then
    selectedCols = { 'icon', 'permissions' }
  elseif vim.g.oil_columns == 3 then
    selectedCols = { 'icon', 'permissions', 'size' }
  else
    selectedCols = { 'icon', 'permissions', 'size', 'mtime' }
  end

  require('oil').set_columns(selectedCols)
end

local function openInFinder()
  local current_path = vim.fn.expand '%:h'
  local clean_path = current_path:gsub('^oil://', '', 1)
  vim.cmd('silent !open ' .. clean_path)
end

return {
  'stevearc/oil.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
    default_file_explorer = true,
    keymaps = {
      -- Custom keymaps for splits so it aligns with the rest of my setup
      ['<C-v>'] = function()
        require('oil').select({ vertical = true }, function()
          vim.api.nvim_exec_autocmds('User', {
            pattern = 'OilSelect',
            data = { method = 'vertical' },
          })
        end)
      end,
      ['<C-s>'] = function()
        require('oil').select({ horizontal = true }, function()
          vim.api.nvim_exec_autocmds('User', {
            pattern = 'OilSelect',
            data = { method = 'horizontal' },
          })
        end)
      end,

      -- Custom keymap for toggling more columns/"information"
      ['<C-i>'] = { toggleColumnInfo, desc = 'Toggle more column information' },

      -- Custom keypmap to reveal directory in Finder for MacOS
      ['gf'] = { openInFinder, desc = 'Reveal in Finder' },

      -- These are all default keymaps
      ['g?'] = { 'actions.show_help', mode = 'n' },
      ['<CR>'] = function()
        require('oil').select(nil, function()
          vim.api.nvim_exec_autocmds('User', {
            pattern = 'OilSelect',
            data = { method = 'buffer' },
          })
        end)
      end,
      ['<C-t>'] = function()
        require('oil').select({ tab = true }, function()
          vim.api.nvim_exec_autocmds('User', {
            pattern = 'OilSelect',
            data = { method = 'tab' },
          })
        end)
      end,
      ['<C-p>'] = 'actions.preview',
      ['<C-c>'] = function()
        require('oil').close()

        vim.defer_fn(function()
          vim.api.nvim_exec_autocmds('User', {
            pattern = 'OilClose',
          })
        end, 0)
      end,
      ['<C-l>'] = 'actions.refresh',
      ['-'] = { 'actions.parent', mode = 'n' },
      ['_'] = { 'actions.open_cwd', mode = 'n' },
      ['`'] = { 'actions.cd', mode = 'n' },
      ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
      ['gs'] = { 'actions.change_sort', mode = 'n' },
      ['gx'] = 'actions.open_external',
      ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
      ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
    },
    -- Disabling defaults to not add back "overridden" keymaps
    use_default_keymaps = false,
  },
  keys = {
    { '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' } },
  },
  config = function(_, opts)
    vim.g.oil_columns = 1
    require('oil').setup(opts)
  end,
}

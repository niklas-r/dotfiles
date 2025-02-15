return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    {
      'bwpge/lualine-pretty-path',
      'folke/snacks.nvim',
      'AndreM222/copilot-lualine',
    },
  },
  -- config = function(_, opts)
  opts = function()
    local lazy_status = require 'lazy.status' -- to configure lazy pending updates count
    local util = require 'util.lualine'

    Snacks.toggle({
      name = 'lualine lsp names',
      get = function()
        return vim.g.custom_lualine_show_lsp_names
      end,
      set = function(state)
        vim.g.custom_lualine_show_lsp_names = state
      end,
    }):map '<leader>tN'

    return {
      options = {
        component_separators = { left = '╲', right = '╱' },
        disabled_filetypes = { 'alpha', 'neo-tree', 'snacks_dashboard' },
        section_separators = { left = '', right = '' },
        ignore_focus = { 'trouble' },
        always_show_tabline = false,
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = util.trunc(130, 3, 0, true),
          },
        },
        lualine_b = {
          {
            'branch',
            fmt = util.trunc(70, 15, 65, true),
          },

          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
            fmt = util.trunc(0, 0, 60, true),
          },
          {
            'diagnostics',
            symbols = vim.g.have_nerd_font and { error = ' ', warn = ' ', info = ' ', hint = ' ' }
              or { error = 'E', warn = 'W', info = 'I', hint = 'H' },
          },
        },
        lualine_c = {
          {
            'pretty_path',
            providers = {
              default = require 'util/pretty_path_harpoon',
            },
            directories = {
              max_depth = 4,
            },
            highlights = {
              newfile = 'LazyProgressDone',
            },
          },
        },
        lualine_x = {
          {
            function()
              return vim.g.macro_recording
            end,
            cond = function()
              return vim.g.macro_recording ~= nil
            end,
            color = 'DiagnosticVirtualTextHint',
            separator = { left = '', right = '' },
          },
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            -- color = { fg = '#3d59a1' },
            fmt = util.trunc(0, 0, 160, true), -- hide when window is < 100 columns
          },
          {
            'copilot',
          },
          {
            util.lsp_status_all,
            fmt = util.trunc(0, 8, 140, false),
          },
          {
            util.encoding_only_if_not_utf8,
            fmt = util.trunc(0, 0, 140, true), -- hide when window is < 80 columns
          },
          {
            util.fileformat_only_if_not_unix,
            fmt = util.trunc(0, 0, 140, true), -- hide when window is < 80 columns
          },
        },
        lualine_y = {
          { 'progress', fmt = util.trunc(0, 0, 40, true) },
        },
        lualine_z = {
          { 'location', fmt = util.trunc(0, 0, 80, true) },
          { util.selectionCount, fmt = util.trunc(0, 0, 80, true) },
        },
      },
      tabline = {
        lualine_a = {
          {
            'tabs',
            mode = 1, -- 0: Shows tab_nr
            -- 1: Shows tab_name
            -- 2: Shows tab_nr + tab_name

            path = 0, -- 0: just shows the filename
            -- 1: shows the relative path and shorten $HOME to ~
            -- 2: shows the full path
            -- 3: shows the full path and shorten $HOME to ~
            show_modified_status = false,
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_sections = {
        lualine_c = {
          {
            'pretty_path',
            -- 'filename',
            -- symbols = {
            --   modified = '+', -- Text to show when the file is modified.
            --   readonly = '', -- Text to show when the file is non-modifiable or readonly.
            -- },
          },
        },
      },
      winbar = {},
      extensions = {
        'lazy',
        'mason',
        'neo-tree',
        'nvim-dap-ui',
        'oil',
        'quickfix',
        'trouble',
      },
    }
  end,
}

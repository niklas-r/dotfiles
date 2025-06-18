return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
      'bwpge/lualine-pretty-path',
      'folke/snacks.nvim',
      'AndreM222/copilot-lualine',
    },
  },
  opts = function()
    local codeCompanionStatus = require 'plugins.lualine.code-companion-status'
    local util = require 'plugins.lualine.utils'
    local trunc_widths = {
      XXS = 50,
      XS = 80,
      S = 100,
      M = 120,
      L = 140,
    }

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
            fmt = util.trunc(trunc_widths.L, 3, 0, true),
          },
        },
        lualine_b = {
          {
            -- 'branch',
            'b:gitsigns_head',
            icon = '',
            fmt = util.trunc(trunc_widths.L, 15, trunc_widths.S, false),
          },
          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
            fmt = util.trunc(0, 0, trunc_widths.XS, true),
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
          {
            'diagnostics',
            symbols = vim.g.have_nerd_font and { error = ' ', warn = ' ', info = ' ', hint = ' ' }
              or { error = 'E', warn = 'W', info = 'I', hint = 'H' },
            fmt = util.trunc(0, 0, trunc_widths.XXS, true),
          },
        },
        lualine_c = {
          {
            'pretty_path',
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
            codeCompanionStatus,
            color = 'LspDiagnosticsVirtualTextWarning',
          },
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
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
            fmt = util.trunc(trunc_widths.L, 8, trunc_widths.M, false),
          },
          -- stylua: ignore
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return { fg = Snacks.util.color("Special") } end,
            fmt = util.trunc(0, 0, trunc_widths.L, false),
          },
          {
            'copilot',
            fmt = util.trunc(0, 8, trunc_widths.S, false),
          },
          {
            util.lsp_status_all,
            fmt = util.trunc(0, 8, trunc_widths.S, false),
          },
          {
            util.encoding_only_if_not_utf8,
            fmt = util.trunc(0, 0, trunc_widths.XXS, true),
          },
          {
            util.fileformat_only_if_not_unix,
            fmt = util.trunc(0, 0, trunc_widths.XXS, true),
          },
        },
        lualine_y = {
          { 'progress', fmt = util.trunc(0, 0, trunc_widths.XXS, true) },
          {
            util.lualine_harpoon(),
            fmt = util.trunc(0, 0, trunc_widths.L, true),
          },
        },
        lualine_z = {
          { 'location', fmt = util.trunc(0, 0, trunc_widths.XXS, true) },
          { util.selectionCount, fmt = util.trunc(0, 0, trunc_widths.XS, true) },
        },
      },
      tabline = {
        lualine_a = {
          {
            'tabs',
            mode = 2, -- 0: Shows tab_nr
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

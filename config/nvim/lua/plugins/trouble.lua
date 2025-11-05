local size = 'win.size={width=60,height=20}'

vim.g.lsp_breadcrumbs_enabled = true

return {
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    lazy = true,
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle ' .. size .. '<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0 ' .. size .. '<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle focus=false ' .. size .. '<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp toggle focus=false win.position=right ' .. size .. '<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle ' .. size .. '<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xq',
        '<cmd>Trouble qflist toggle ' .. size .. '<cr>',
        desc = 'Quickfix List (Trouble)',
      },
      {
        '<leader>xt',
        '<cmd>Trouble todo toggle ' .. size .. '<cr>',
        desc = 'Todo List (Trouble)',
      },
    },
  },

  -- Add action to Snacks picker to add results to Trouble
  {
    'folke/trouble.nvim',
    optional = true,
    specs = {
      'folke/snacks.nvim',
      opts = function(_, opts)
        return vim.tbl_deep_extend('force', opts or {}, {
          picker = {
            actions = require('trouble.sources.snacks').actions,
            win = {
              input = {
                keys = {
                  ['<c-t>'] = {
                    'trouble_open',
                    mode = { 'n', 'i' },
                  },
                },
              },
            },
          },
        })
      end,
    },
  },

  -- Add breadcrumbs to lualine using Trouble symbols source
  {
    'folke/trouble.nvim',
    optional = true,
    depedencies = { 'folke/snacks.nvim' },
    specs = {
      'nvim-lualine/lualine.nvim',
      init = function()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'VeryLazy',
          callback = function()
            Snacks.toggle({
              name = 'LSP breadcrumbs',
              get = function()
                return vim.g.lsp_breadcrumbs_enabled
              end,
              set = function(state)
                vim.g.lsp_breadcrumbs_enabled = state
                require('lualine').refresh { force = true, placement = { 'statusline' } }
              end,
            }):map '<leader>tB'
          end,
        })
      end,
      opts = function(_, opts)
        local trouble = require 'trouble'
        local symbols = trouble.statusline {
          mode = 'lsp_document_symbols',
          groups = {},
          title = false,
          filter = { range = true },
          format = '{kind_icon}{symbol.name:Normal}',
          -- The following line is needed to fix the background color
          -- Set it to the lualine section you want to use
          hl_group = 'lualine_c_normal',
        }

        local merged_opts = vim.tbl_deep_extend('force', opts or {}, {})
        merged_opts.sections = merged_opts.sections or {}
        merged_opts.sections.lualine_c = merged_opts.sections.lualine_c or {}
        table.insert(merged_opts.sections.lualine_c, {
          symbols.get,
          cond = function()
            return vim.g.lsp_breadcrumbs_enabled and symbols.has()
          end,
        })

        -- vim.print(vim.inspect(merged_opts))
        return merged_opts
      end,
    },
  },
}

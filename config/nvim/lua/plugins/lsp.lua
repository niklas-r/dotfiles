return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'LazyVim', words = { 'LazyVim' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
        { path = 'mcphub.nvim', words = { 'MCPHub' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Allows extra capabilities provided by blink-cmp
      'saghen/blink.cmp',
      'dmmulroy/ts-error-translator.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode, customOpts)
            mode = mode or 'n'
            local opts = vim.tbl_extend('force', { buffer = event.buf, desc = 'LSP: ' .. desc }, customOpts or {})
            vim.keymap.set(mode, keys, func, opts)
          end

          map('<leader>rn', function()
            return ':IncRename ' .. vim.fn.expand '<cword>'
          end, '[R]e[n]ame', 'n', { expr = true })
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
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
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
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
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
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

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Place languages servers to be installed here
      local servers = {
        -- ts_ls = {},
        vtsls = {},
        eslint = {}, -- Using ESLint LSP for code actions
        tailwindcss = {
          hovers = true,
          suggestions = true,
          -- Only load Tailwind LSP if a config file is found in root
          root_dir = function(fname)
            local root_pattern = require('lspconfig').util.root_pattern('tailwind.config.cjs', 'tailwind.config.js', 'postcss.config.js')
            return root_pattern(fname)
          end,
        },
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
        gh_actions_ls = {},
        bashls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      require('mason').setup()

      -- Place other tools to be installed by Mason here, such as linters/formatters etc.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'prettierd', -- Using prettierd with conform.nvim for faster formatting
        'beautysh', -- Bash, Zsh etc formatter
        'jq', -- Fast JSON formatter and more
        'jsonlint',
        'yamllint',
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

      -- This custom config is only necessary until https://github.com/williamboman/mason-lspconfig.nvim/pull/506 is merged
      local gh_token = vim.fn.system 'gh auth token'
      gh_token = gh_token:gsub('%s+', '') -- Remove trailing newline

      local util = require 'lspconfig.util'

      local config = {
        cmd = { 'gh-actions-language-server', '--stdio' },
        filetypes = { 'yaml.github' },
        root_dir = util.root_pattern '.github',
        single_file_support = true,
        capabilities = {
          workspace = {
            didChangeWorkspaceFolders = {
              dynamicRegistration = true,
            },
          },
        },
        -- These settings will be necesarry in the future though
        settings = {
          sessionToken = gh_token,
        },
      }

      require('lspconfig').gh_actions_ls.setup(config)
    end,
  },
}

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
      'marilari88/twoslash-queries.nvim',
    },
    config = function()
      local gh_token = vim.fn.system 'gh auth token'
      gh_token = gh_token:gsub('%s+', '') -- Remove trailing newline

      -- Place languages servers to be installed here
      ---@type table<string, vim.lsp.ClientConfig>
      local servers = {
        -- ts_ls = {},
        vtsls = {
          on_attach = function(client, bufnr)
            require('twoslash-queries').attach(client, bufnr)
          end,
        },
        eslint = {}, -- Using ESLint LSP for code actions
        tailwindcss = {
          hovers = true,
          suggestions = true,
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
        gh_actions_ls = {
          settings = {
            sessionToken = gh_token,
          },
        },
        bashls = {},
        marksman = {},
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
        'tree-sitter-cli', -- Required by nvim-treesitter main branch
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- This bridges Mason with nvim-lspconfig and calls vim.lsp.enable() for each server
      require('mason-lspconfig').setup()

      -- This will override any default LSP config, check `:h lsp-config` for info on merge rules
      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
      end
    end,
  },
}

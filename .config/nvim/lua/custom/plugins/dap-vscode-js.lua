return {
  'mxsdev/nvim-dap-vscode-js',
  lazy = true,
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  config = function()
    require('dap-vscode-js').setup {
      -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
      debugger_path = vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug',
      -- debugger_path = '(runtimedir)/lazy/vscode-js-debug', -- Path to vscode-js-debug installation.
      -- debugger_cmd = { 'js-debug-adapter' }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
      adapters = { -- which adapters to register in nvim-dap
        'pwa-node',
        'pwa-chrome',
        -- 'pwa-msedge',
        -- 'node-terminal',
        -- 'pwa-extensionHost',
      },
      -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
      -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
      -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
    }

    for _, language in ipairs { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' } do
      require('dap').configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Lanch Chrome (pwa-chrome, select port)',
          -- program = '${file}',
          -- cwd = vim.fn.getcwd(),
          -- sourceMaps = true,
          port = function()
            return vim.fn.input('Select port: ', 5173)
          end,
          url = 'http://localhost:${port}',
          webRoot = function()
            return vim.fn.input('Select web root:', '${workspaceFolder}/src')
          end,
        },
      }
    end
  end,
}

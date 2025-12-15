local js_settings = {
  'prettierd',
}

local format = function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end

vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})

vim.api.nvim_create_user_command('FormatEnable', function(args)
  if args.bang then
    -- FormatEnable! will enable formatting just for this buffer
    vim.b.disable_autoformat = false
  else
    vim.g.disable_autoformat = false
  end
end, {
  desc = 'Re-enable autoformat-on-save',
  bang = true,
})

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>ff',
      format,
      mode = 'n',
      desc = '[F]ormat File',
    },
    {
      '<leader>ff',
      format,
      mode = 'v',
      desc = '[F]ormat File',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true, json = true, yml = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
      }
    end,
    -- Formatters can be installed with Mason
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      javascript = js_settings,
      typescript = js_settings,
      javascriptreact = js_settings,
      typescriptreact = js_settings,
      yaml = js_settings,
      sh = { 'beautysh' },
      zsh = { 'beautysh' },
      json = { 'jq' },
    },
  },
}

local js_symbols = {
  'Class',
  'Constructor',
  'Enum',
  'Function',
  'Interface',
  'Method',
  'Module',
  'Namespace',
  'Package',
  'Struct',
  'Trait',
  -- extras
  'Variable',
  'Constant',
}

return {
  'folke/snacks.nvim',
  keys = {
    -- stylua: ignore start
    { "<leader>sf", function() Snacks.picker.files { matcher = { frecency = true }, hidden = true } end, desc = "[F]iles" },
    ---@diagnostic disable-next-line: undefined-field
    { "<leader>sF", function() Snacks.picker.smart { hidden = true } end, desc = "[F]iles Smart" },
    { "<leader><space>", function() Snacks.picker.buffers() end, desc = "[B]uffers" },
    -- utilities
    { "<leader>s:", function() Snacks.picker.command_history() end, desc = "[:] Command History" },
    ---@diagnostic disable-next-line: undefined-field
    { "<leader>su", function() Snacks.picker.undo() end, desc = "[U]ndo tree" },
    -- git pickers are defined in lua/plugins/git.lua
    -- find
    ---@diagnostic disable-next-line: assign-type-mismatch
    { "<leader>sn", function() Snacks.picker.files({ cwd = vim.fn.stdpath "config", title = "Neovim config files" }) end, desc = "[N]eovim files" },
    { "<leader>sp", function() Snacks.picker.files({ cwd = vim.fn.stdpath "data" .. "/lazy", title = "Lazy plugin files" }) end, desc = "[P]lugin Files" },
    { "<leader>s.", function() Snacks.picker.recent() end, desc = "Recent Files [.]" },
    -- Grep
    { "<leader>sg", function() Snacks.picker.grep { hidden = true } end, desc = "[G]rep" },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "[B]uffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Open [B]uffers" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "current [W]ord (or selection)", mode = { "n", "x" } },
    -- search
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "[D]iagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "[H]elp" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "[K]eymaps" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "[R]esume" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "[Q]uickfix list" },
    { "<leader>sc", function() Snacks.picker.colorschemes() end, desc = "[C]olorschemes" },
    { "g?S", function() Snacks.picker.grep({
      title = "Debug Prints",
      search = "DEBUGPRINT\\[\\d+\\]",
      live = false,
    }) end, desc = "Search debug prints" },
    -- LSP
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "[G]oto [D]efinition" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "[G]oto [R]eferences" },
    { "gD", function() Snacks.picker.lsp_declarations() end, nowait = true, desc = "[G]oto [D]eclarations" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "[G]oto [I]mplementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "[G]oto T[y]pe Definition" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols {
      filter = {
        typescript = js_symbols,
        typescriptreact = js_symbols,
        javascript = js_symbols,
        javascriptreact = js_symbols,
      },
    } end, desc = "LSP [S]ymbols" },
    ---@diagnostic disable-next-line: undefined-field
    { "<leader>sW", function() Snacks.picker.lsp_workspace_symbols {
      filter = {
        typescript = js_symbols,
        typescriptreact = js_symbols,
        javascript = js_symbols,
        javascriptreact = js_symbols,
      },
    } end, desc = "LSP [W]orkspace Symbols" },
    -- stylua: ignore end
  },
  opts = {
    picker = {},
  },
}

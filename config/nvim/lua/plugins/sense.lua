-- This plugin shows diagnostics in the statuscolumn and virtual text outside of the window.
return {
  'boltlessengineer/sense.nvim',
  event = 'VeryLazy',
  enabled = false,
  init = function()
    -- Unorthodox way for configuring this Lazy plugin...
    ---@type sense.Config
    vim.g.sense_nvim = {
      presets = {
        ---@type sense.Config.Presets.VirtualText
        virtualtext = {
          enabled = true,
        },
        ---@type sense.Config.Presets.StatusColumn
        statuscolumn = {
          enabled = true,
        },
      },
    }

    -- Just require to get LSP to read types
    require 'sense'
  end,
}

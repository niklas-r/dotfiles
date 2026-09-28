return {
  'tumillanino/semgrep.nvim',
  dependencies = {},
  cmd = {
    'SemgrepScan',
    'SemgrepScanWorkspace',
    'SemgrepFindings',
    'SemgrepFix',
  },
  opts = {}, -- same as require("semgrep").setup({})
  config = function(_, opts)
    require('semgrep').setup(opts)
    -- Route :SemgrepScanWorkspace / :SemgrepFindings to the snacks picker.
    require('semgrep.pickers').open = function()
      require('plugins.snacks.utils.semgrep').open()
    end
  end,
}

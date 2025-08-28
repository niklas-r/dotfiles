vim.g.colorful_winsep_enabled = true
return {
  'nvim-zh/colorful-winsep.nvim',
  opts = {
    excluded_ft = {
      'packer',
      'TelescopePrompt',
      'mason',
      'snacks_dashboard',
      'snacks_picker_input',
      'snacks_picker_list',
    },
  },
  event = { 'WinLeave' },
  setup = function(_, opts)
    require('colorful-winsep').setup(opts)

    if vim.g.colorful_winsep_enabled then
      vim.cmd 'Winsep enable'
    else
      vim.cmd 'Winsep disable'
    end
  end,
}

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    file_types = { 'markdown', 'codecompanion' },
    html = {
      enabled = true,
      tag = {
        buf = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
        file = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
        help = { icon = '󰘥 ', highlight = 'CodeCompanionChatVariable' },
        image = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
        symbols = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
        url = { icon = '󰖟 ', highlight = 'CodeCompanionChatVariable' },
        var = { icon = ' ', highlight = 'CodeCompanionChatVariable' },
        tool = { icon = ' ', highlight = 'CodeCompanionChatTool' },
        user = { icon = ' ', highlight = 'CodeCompanionChatTool' },
        group = { icon = ' ', highlight = 'CodeCompanionChatToolGroup' },
      },
    },
  },
  ft = { 'markdown', 'codecompanion' },
  completions = {
    lsp = { enabled = true },
  },
}

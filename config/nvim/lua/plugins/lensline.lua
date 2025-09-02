return {
  'oribarilan/lensline.nvim',
  branch = 'release/1.x',
  event = 'LspAttach',
  opts = {
    providers = {
      {
        name = 'references',
        enabled = true, -- enable references provider
        quiet_lsp = true, -- suppress noisy LSP log messages (e.g., Pyright reference spam)
      },
      {
        name = 'last_author',
        enabled = true, -- enabled by default with caching optimization
        cache_max_files = 50, -- maximum number of files to cache blame data for (default: 50)
      },
      {
        name = 'complexity',
        enabled = false, -- disabled by default - enable explicitly to use
        min_level = 'L', -- only show L (Large) and XL (Extra Large) complexity by default
      },
    },
    style = {
      placement = 'inline',
      prefix = '',
    },
    render = 'focused', -- or "all" for showing lenses in all functions
  },
}

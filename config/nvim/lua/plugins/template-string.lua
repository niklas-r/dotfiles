return {
  'axelvc/template-string.nvim',
  ft = {
    'html',
    'typescript',
    'javascript',
    'typescriptreact',
    'javascriptreact',
    'vue',
    'svelte',
    'python',
    'cs',
  },
  opts = {
    remove_template_string = true, -- remove backticks when there are no template strings
    restore_quotes = {
      -- quotes used when "remove_template_string" option is enabled
      normal = [[']],
      jsx = [["]],
    },
  },
}

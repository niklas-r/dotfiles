vim.filetype.add {
  extension = {
    conf = 'conf',
    env = 'dotenv',
  },
  filename = {
    ['.env'] = 'dotenv',
    ['tsconfig.json'] = 'jsonc',
    ['.eslintrc.json'] = 'jsonc',
    ['.yamlfmt'] = 'yaml',
  },
  pattern = {
    ['%.env%.[%w_.-]+'] = 'dotenv',
  },
}

vim.filetype.add {
  pattern = {
    ['.*/%.github[%w/]+workflows[%w/]+.*%.ya?ml'] = 'yaml.github',
  },
}

return {}

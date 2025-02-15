return {
  'rmagatti/goto-preview',
  event = 'BufEnter',
  config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
  keys = {
    { 'gpd', '<cmd>lua require("goto-preview").goto_preview_definition()<CR>', desc = '[G]oto [P]review [D]efinition' },
    { 'gpt', '<cmd>lua require("goto-preview").goto_preview_type_definition()<CR>', desc = '[G]oto [P]review [T]ype Definition' },
    { 'gpi', '<cmd>lua require("goto-preview").goto_preview_implementation()<CR>', desc = '[G]oto [P]review [I]implemention' },
    { 'gpD', '<cmd>lua require("goto-preview").goto_preview_declaration()<CR>', desc = '[G]oto [P]review [D]eclaration' },
    { 'gpx', '<cmd>lua require("goto-preview").close_all_win()<CR>', desc = '[G]oto [P]review E[x]it All Windows' },
    { 'gpr', '<cmd>lua require("goto-preview").goto_preview_references()<CR>', desc = '[G]oto [P]review [R]eferences' },
  },
}

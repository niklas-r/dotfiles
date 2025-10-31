return {
  'altermo/ultimate-autopair.nvim',
  enabled = true,
  event = { 'InsertEnter', 'CmdlineEnter' },
  branch = 'v0.6', --recommended as each new version will have breaking changes
  opts = {
    --Config goes here
    -- See default config `:help ultimate-autopair-default-config`
    tabout = {
      enable = true,
      map = '<C-Tab>',
      cmap = '<C-Tab>',
      hopout = true,
    },
    fastwarp = {
      multi = true,
      {},
      {
        faster = true,
        map = '<C-e>',
        cmap = '<C-e>',
        -- rmap and rcmap doesn't seem to work with faster, the nomal behaviour is used instead
        -- I can live with it
        -- rmap = '<C-S-e>',
        -- rcmap = '<C-S-e>',
      },
    },
  },
}

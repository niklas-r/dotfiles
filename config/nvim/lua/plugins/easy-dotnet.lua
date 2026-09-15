-- easy-dotnet has to be a start plugin: its `setup()` registers filetype rules,
-- enables the roslyn/projx LSPs, attaches csproj mappings and registers the dap
-- adapter. Lazy-loading it on `ft` makes several of those fire too late.
--
-- Instead it is disabled outright outside of .NET projects. That saves ~50ms of
-- startup everywhere else, since easy-dotnet `require`s "dap" and therefore drags
-- in nvim-dap, mason and mason-nvim-dap with it.
--
-- Note: `cond` is evaluated once, at startup -- `:cd`-ing into a .NET project later
-- will not enable the plugin for that session.
local function is_dotnet_project()
  local cwd = vim.uv.cwd()
  if not cwd then
    return false
  end

  -- cwd itself, or any ancestor of it (started inside a subdirectory of a repo).
  local upward = vim.fs.find(function(name)
    return name:match '%.slnx?$' ~= nil or name:match '%.[cf]sproj$' ~= nil
  end, { path = cwd, upward = true, type = 'file', limit = 1 })
  if #upward > 0 then
    return true
  end

  -- Started at the repo root, with the projects below it. Deliberately two
  -- bounded globs instead of a blanket `*/*/` scan: that costs ~58ms in a
  -- directory like $HOME, i.e. more than loading the plugin would have.
  -- Note: glob() has no nested or empty brace alternation, so `{,*/,*/*/}`
  -- style patterns are not an option.
  for _, pattern in ipairs {
    '/*/*.{sln,slnx,csproj,fsproj}',
    '/{src,source,Source,test,tests,Tests}/*/*.{csproj,fsproj}',
  } do
    if vim.fn.glob(cwd .. pattern, true, true)[1] ~= nil then
      return true
    end
  end

  return false
end

return {
  'GustavEikaas/easy-dotnet.nvim',
  cond = is_dotnet_project,
  dependencies = { 'nvim-lua/plenary.nvim', 'folke/snacks.nvim' },
  config = function()
    require('easy-dotnet').setup {
      test_runner = {
        neotest_integration = true,
      },
    }
  end,
}

return {
  'pwntester/octo.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  cmd = { 'Octo' }, -- Lazy load on command
  keys = {
    -- Issues
    { '<leader>ghil', '<cmd>Octo issue list<cr>', desc = 'List Issues' },
    { '<leader>ghis', '<cmd>Octo issue search<cr>', desc = 'Search Issues' },
    { '<leader>ghic', '<cmd>Octo issue create<cr>', desc = 'Create Issue' },
    { '<leader>ghie', '<cmd>Octo issue edit<cr>', desc = 'Edit Issue' },
    { '<leader>ghio', '<cmd>Octo issue close<cr>', desc = 'Close Issue' },
    { '<leader>ghir', '<cmd>Octo issue reopen<cr>', desc = 'Reopen Issue' },
    { '<leader>ghib', '<cmd>Octo issue browser<cr>', desc = 'Open in Browser' },
    { '<leader>ghiu', '<cmd>Octo issue url<cr>', desc = 'Copy URL' },
    { '<leader>ghid', '<cmd>Octo issue develop<cr>', desc = 'Create Branch' },
    { '<leader>ghip', '<cmd>Octo issue pin<cr>', desc = 'Pin Issue' },
    { '<leader>ghiP', '<cmd>Octo issue unpin<cr>', desc = 'Unpin Issue' },
    { '<leader>ghiR', '<cmd>Octo issue reload<cr>', desc = 'Reload Issue' },

    -- Pull Requests
    { '<leader>ghpl', '<cmd>Octo pr list<cr>', desc = 'List PRs' },
    { '<leader>ghps', '<cmd>Octo pr search<cr>', desc = 'Search PRs' },
    { '<leader>ghpc', '<cmd>Octo pr create<cr>', desc = 'Create PR' },
    { '<leader>ghpe', '<cmd>Octo pr edit<cr>', desc = 'Edit PR' },
    { '<leader>ghpo', '<cmd>Octo pr close<cr>', desc = 'Close PR' },
    { '<leader>ghpr', '<cmd>Octo pr reopen<cr>', desc = 'Reopen PR' },
    { '<leader>ghpb', '<cmd>Octo pr browser<cr>', desc = 'Open in Browser' },
    { '<leader>ghpu', '<cmd>Octo pr url<cr>', desc = 'Copy URL' },
    { '<leader>ghpR', '<cmd>Octo pr reload<cr>', desc = 'Reload PR' },
    { '<leader>ghpC', '<cmd>Octo pr checkout<cr>', desc = 'Checkout PR' },
    { '<leader>ghpm', '<cmd>Octo pr merge<cr>', desc = 'Merge PR' },
    { '<leader>ghpd', '<cmd>Octo pr diff<cr>', desc = 'Show Diff' },
    { '<leader>ghpk', '<cmd>Octo pr checks<cr>', desc = 'Show Checks' },
    { '<leader>ghpw', '<cmd>Octo pr changes<cr>', desc = 'Show Changes' },
    { '<leader>ghpx', '<cmd>Octo pr commits<cr>', desc = 'Show Commits' },
    { '<leader>ghpy', '<cmd>Octo pr ready<cr>', desc = 'Mark Ready' },
    { '<leader>ghpz', '<cmd>Octo pr draft<cr>', desc = 'Mark Draft' },
    { '<leader>ghpn', '<cmd>Octo pr runs<cr>', desc = 'List Workflow Runs' },

    -- Reviews
    { '<leader>ghrs', '<cmd>Octo review start<cr>', desc = 'Start Review' },
    { '<leader>ghrc', '<cmd>Octo review comments<cr>', desc = 'View Comments' },
    { '<leader>ghrS', '<cmd>Octo review submit<cr>', desc = 'Submit Review' },
    { '<leader>ghrr', '<cmd>Octo review resume<cr>', desc = 'Resume Review' },
    { '<leader>ghrd', '<cmd>Octo review discard<cr>', desc = 'Discard Review' },
    { '<leader>ghrx', '<cmd>Octo review commit<cr>', desc = 'Review Commit' },
    { '<leader>ghro', '<cmd>Octo review close<cr>', desc = 'Close Review' },

    -- Threads
    { '<leader>ghtr', '<cmd>Octo thread resolve<cr>', desc = 'Resolve Thread' },
    { '<leader>ghtu', '<cmd>Octo thread unresolve<cr>', desc = 'Unresolve Thread' },

    -- Comments
    { '<leader>ghca', '<cmd>Octo comment add<cr>', desc = 'Add Comment' },
    { '<leader>ghcs', '<cmd>Octo comment suggest<cr>', desc = 'Add Suggestion' },
    { '<leader>ghcd', '<cmd>Octo comment delete<cr>', desc = 'Delete Comment' },
    { '<leader>ghcu', '<cmd>Octo comment url<cr>', desc = 'Copy Comment URL' },

    -- Repos
    { '<leader>ghrl', '<cmd>Octo repo list<cr>', desc = 'List Repos' },
    { '<leader>ghrf', '<cmd>Octo repo fork<cr>', desc = 'Fork Repo' },
    { '<leader>ghrb', '<cmd>Octo repo browser<cr>', desc = 'Open in Browser' },
    { '<leader>ghru', '<cmd>Octo repo url<cr>', desc = 'Copy URL' },
    { '<leader>ghrv', '<cmd>Octo repo view<cr>', desc = 'View Repo' },

    -- Labels
    { '<leader>ghla', '<cmd>Octo label add<cr>', desc = 'Add Label' },
    { '<leader>ghlr', '<cmd>Octo label remove<cr>', desc = 'Remove Label' },
    { '<leader>ghlc', '<cmd>Octo label create<cr>', desc = 'Create Label' },
    { '<leader>ghld', '<cmd>Octo label delete<cr>', desc = 'Delete Label' },
    { '<leader>ghle', '<cmd>Octo label edit<cr>', desc = 'Edit Label' },

    -- Assignees
    { '<leader>ghaa', '<cmd>Octo assignee add<cr>', desc = 'Add Assignee' },
    { '<leader>ghar', '<cmd>Octo assignee remove<cr>', desc = 'Remove Assignee' },

    -- Reviewers
    { '<leader>ghva', '<cmd>Octo reviewer add<cr>', desc = 'Add Reviewer' },

    -- Milestones
    { '<leader>ghma', '<cmd>Octo milestone add<cr>', desc = 'Add Milestone' },
    { '<leader>ghmr', '<cmd>Octo milestone remove<cr>', desc = 'Remove Milestone' },
    { '<leader>ghmc', '<cmd>Octo milestone create<cr>', desc = 'Create Milestone' },
    { '<leader>ghml', '<cmd>Octo milestone list<cr>', desc = 'List Milestones' },

    -- Cards
    { '<leader>ghka', '<cmd>Octo card add<cr>', desc = 'Add Card' },
    { '<leader>ghkr', '<cmd>Octo card remove<cr>', desc = 'Remove Card' },
    { '<leader>ghkm', '<cmd>Octo card move<cr>', desc = 'Move Card' },

    -- Gists
    { '<leader>ghgl', '<cmd>Octo gist list<cr>', desc = 'List Gists' },

    -- Search
    { '<leader>ghs', '<cmd>Octo search<cr>', desc = 'Search GitHub' },

    -- Notifications
    { '<leader>ghn', '<cmd>Octo notification list<cr>', desc = 'List Notifications' },

    -- Discussions
    { '<leader>ghdl', '<cmd>Octo discussion list<cr>', desc = 'List Discussions' },
    { '<leader>ghdc', '<cmd>Octo discussion create<cr>', desc = 'Create Discussion' },
    { '<leader>ghdr', '<cmd>Octo discussion reload<cr>', desc = 'Reload Discussion' },
    { '<leader>ghdo', '<cmd>Octo discussion close<cr>', desc = 'Close Discussion' },
    { '<leader>ghdm', '<cmd>Octo discussion mark<cr>', desc = 'Mark as Answer' },
    { '<leader>ghdu', '<cmd>Octo discussion unmark<cr>', desc = 'Unmark as Answer' },
    { '<leader>ghdR', '<cmd>Octo discussion reopen<cr>', desc = 'Reopen Discussion' },
    { '<leader>ghds', '<cmd>Octo discussion search<cr>', desc = 'Search Discussions' },

    -- Parent Issues
    { '<leader>ghpa', '<cmd>Octo parent add<cr>', desc = 'Add Parent Issue' },
    { '<leader>ghpr', '<cmd>Octo parent remove<cr>', desc = 'Remove Parent Issue' },
    { '<leader>ghpe', '<cmd>Octo parent edit<cr>', desc = 'Edit Parent Issue' },

    -- Workflow Runs
    { '<leader>ghwl', '<cmd>Octo run list<cr>', desc = 'List Workflow Runs' },
  },
  init = function()
    local wk = require 'which-key'
    wk.add {
      { '<leader>gh', group = 'Git[h]ub' },
      { '<leader>ghi', group = '[I]ssues' },
      { '<leader>ghp', group = '[P]ull Request' },
      { '<leader>ghr', group = '[R]epos/[R]eview' },
      { '<leader>ght', group = '[T]hreads' },
      { '<leader>ghc', group = '[C]omments' },
      { '<leader>ghl', group = '[L]abels' },
      { '<leader>gha', group = '[A]ssignees' },
      { '<leader>ghv', group = 'Re[v]iewers' },
      { '<leader>ghm', group = '[M]ilestones' },
      { '<leader>ghk', group = 'Project [C]ards' },
      { '<leader>ghg', group = '[G]ists' },
      { '<leader>ghs', group = '[S]earch' },
      { '<leader>ghn', group = '[N]otifications' },
      { '<leader>ghd', group = '[D]iscussions' },
      { '<leader>ghw', group = '[W]orkflow Runs' },
    }
  end,
  opts = {
    picker = 'snacks',
  },
}

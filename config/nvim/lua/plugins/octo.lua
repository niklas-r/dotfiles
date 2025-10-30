return {
  'pwntester/octo.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
    'nvim-tree/nvim-web-devicons',
    'folke/which-key.nvim',
  },
  cmd = { 'Octo' }, -- Lazy load on command
  opts = {
    -- This will enable LSP powered features during review but requires us to checkout the branch for review
    use_local_fs = true,
    picker = 'snacks',
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        local wk = require 'which-key'

        wk.add {
          { '<leader>gh', group = 'Git[h]ub' },

          -- Issues
          { '<leader>ghi', group = '[I]ssues' },
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
          { '<leader>ghp', group = '[P]ull Request' },
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
          { '<leader>ghr', group = '[R]eview' },
          { '<leader>ghrs', '<cmd>Octo review start<cr>', desc = 'Start Review' },
          { '<leader>ghrc', '<cmd>Octo review comments<cr>', desc = 'View Comments' },
          { '<leader>ghrS', '<cmd>Octo review submit<cr>', desc = 'Submit Review' },
          { '<leader>ghrr', '<cmd>Octo review resume<cr>', desc = 'Resume Review' },
          { '<leader>ghrd', '<cmd>Octo review discard<cr>', desc = 'Discard Review' },
          { '<leader>ghrx', '<cmd>Octo review commit<cr>', desc = 'Review Commit' },
          { '<leader>ghro', '<cmd>Octo review close<cr>', desc = 'Close Review' },

          -- Threads
          { '<leader>ght', group = '[T]hreads' },
          { '<leader>ghtr', '<cmd>Octo thread resolve<cr>', desc = 'Resolve Thread' },
          { '<leader>ghtu', '<cmd>Octo thread unresolve<cr>', desc = 'Unresolve Thread' },

          -- Comments
          { '<leader>ghc', group = '[C]omments' },
          { '<leader>ghca', '<cmd>Octo comment add<cr>', desc = 'Add Comment' },
          { '<leader>ghcs', '<cmd>Octo comment suggest<cr>', desc = 'Add Suggestion' },
          { '<leader>ghcd', '<cmd>Octo comment delete<cr>', desc = 'Delete Comment' },
          { '<leader>ghcu', '<cmd>Octo comment url<cr>', desc = 'Copy Comment URL' },

          -- Labels
          { '<leader>ghl', group = '[L]abels' },
          { '<leader>ghla', '<cmd>Octo label add<cr>', desc = 'Add Label' },
          { '<leader>ghlr', '<cmd>Octo label remove<cr>', desc = 'Remove Label' },
          { '<leader>ghlc', '<cmd>Octo label create<cr>', desc = 'Create Label' },
          { '<leader>ghld', '<cmd>Octo label delete<cr>', desc = 'Delete Label' },
          { '<leader>ghle', '<cmd>Octo label edit<cr>', desc = 'Edit Label' },

          -- Assignees
          { '<leader>gha', group = '[A]ssignees' },
          { '<leader>ghaa', '<cmd>Octo assignee add<cr>', desc = 'Add Assignee' },
          { '<leader>ghar', '<cmd>Octo assignee remove<cr>', desc = 'Remove Assignee' },

          -- Reviewers
          { '<leader>ghv', group = 'Re[v]iewers' },
          { '<leader>ghva', '<cmd>Octo reviewer add<cr>', desc = 'Add Reviewer' },

          -- Notifications
          { '<leader>ghn', '<cmd>Octo notification list<cr>', desc = 'List [N]otifications' },

          -- Workflow Runs
          { '<leader>ghw', group = '[W]orkflow Runs' },
          { '<leader>ghwl', '<cmd>Octo run list<cr>', desc = 'List Workflow Runs' },
        }
      end,
    })
  end,
}

return {
  {
    'FabijanZulj/blame.nvim',
    event = 'BufRead',
    config = function()
      require('blame').setup {}

      vim.api.nvim_create_autocmd('User', {
        pattern = 'BlameViewOpened',
        callback = function(event)
          local wk = require 'which-key'
          local map = function(key, desc)
            wk.add { key, desc = desc, buffer = event.buf, nowait = true, silent = true, noremap = true }
          end
          -- event.buf
          map('i', 'Blame: Commit info')
          map('<TAB>', 'Blame: Stack push')
          map('<BS>', 'Blame: Stack pop')
          map('<CR>', 'Blame: Show commit')
          map('<ESC>', 'Blame: close')
          map('q', 'Blame: close')
        end,
      })
    end,
  },

  {
    'sindrets/diffview.nvim',
    event = 'BufReadPre',
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'folke/snacks.nvim',
      'FabijanZulj/blame.nvim',
    },
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']g', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next [G]it change' })

        map('n', '[g', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous [G]it change' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage/unstage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk_inline, { desc = 'git [p]review hunk inline' })
        map('n', '<leader>hP', gitsigns.preview_hunk, { desc = 'git [P]review hunk' })
        map('n', '<leader>hQ', function()
          gitsigns.setqflist 'all'
        end, { desc = 'git [Q]uickfix list all changes' })
        map('n', '<leader>hq', gitsigns.setqflist, { desc = 'git [q]uickfix list current buffer' })
        map('n', '<leader>hb', function()
          Snacks.git.blame_line()
        end, { desc = 'git [b]lame line' })
        map('n', '<leader>hB', function()
          -- Uses blame.nvim
          vim.cmd 'BlameToggle window'
        end, { desc = 'git [B]lame file' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
      end,
      -- This will open up Trouble instead of loclist and quickfixlist
      trouble = true,
      current_line_blame_opts = {
        delay = 500,
      },
      current_line_blame_formatter = ' <author>, <author_time:%R>',
    },
  },

  {
    'folke/snacks.nvim',
    dependencies = {
      'sindrets/diffview.nvim',
    },
    keys = {
      -- stylua: ignore start
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "[B]ranches" },
      { "<leader>gl", function() Snacks.picker.git_log {
        confirm = function(picker, item)
          picker:close()
          if item then
            vim.cmd('DiffviewOpen ' .. item.commit .. '^!')
          end
        end,
      } end, desc = "[L]og" },
      { "<leader>gL", function() Snacks.picker.git_log_line {
        confirm = function(picker, item)
          picker:close()
          if item then
            vim.cmd('DiffviewOpen ' .. item.commit .. '^!')
          end
        end,
      } end, desc = "Log [L]ine" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "[S]tatus" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "[S]tash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "[D]iff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file {
        confirm = function(picker, item)
          picker:close()
          if item then
            vim.cmd('DiffviewFileHistory ' .. item.file .. ' --follow')
          end
        end,
      } end, desc = "Log [F]ile" },
      -- stylua: ignore end
    },
    opts = {
      picker = {},
    },
  },

  {
    'folke/snacks.nvim',
    keys = {
      -- stylua: ignore start
      { '<leader>lg', function() Snacks.lazygit() end, desc = '[L]azy[g]it', },
      -- stylua: ignore end
    },
    opts = {
      lazygit = { enabled = true },
    },
  },
}

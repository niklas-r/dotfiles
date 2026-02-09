local function walk_in_codediff(current_commit)
  vim.system({ 'git', 'rev-parse', '--short ', current_commit .. '^' }, { test = true }, function(obj)
    local code = obj.code or 0
    if code ~= 0 then
      vim.notify('Cannot find parent (Root commit?)', vim.log.levels.WARN)
    else
      local parent_commit = vim.trim(obj.stdout)
      parent_commit = string.sub(parent_commit:match '[a-f0-9]+', 1, 7)
      local cmd = string.format('CodeDiff %s %s', parent_commit, current_commit)
      vim.notify('Diffing: ' .. parent_commit .. ' -> ' .. current_commit)
      vim.schedule(function()
        vim.cmd(cmd)
      end)
    end
  end)
end

local function git_pickaxe(opts)
  opts = opts or {}
  local is_global = opts.global or false
  local current_file = vim.api.nvim_buf_get_name(0)
  if not is_global and (current_file == '' or current_file == nil) then
    vim.notify('Buffer is not a file, switching to global search', vim.log.levels.WARN)
    is_global = true
  end

  local title_scope = is_global and 'repository' or vim.fn.fnamemodify(current_file, ':t')
  vim.ui.input({ prompt = 'Git Search in ' .. title_scope .. ': ' }, function(query)
    if not query or query == '' then
      return
    end

    -- set keyword highlight within Snacks.picker
    vim.fn.setreg('/', query)
    local old_hl = vim.opt.hlsearch
    vim.opt.hlsearch = true

    local args = {
      '-G' .. query,
    }

    if not is_global then
      table.insert(args, '--')
      table.insert(args, current_file)
    end

    Snacks.picker.git_log {
      title = 'Git Search: "' .. query .. '" (' .. title_scope .. ')',
      cmd_args = args,
      confirm = function(picker, item)
        picker:close()
        walk_in_codediff(item.commit)
      end,
      on_close = function()
        -- remove keyword highlight
        vim.opt.hlsearch = old_hl
        vim.cmd 'noh'
      end,
    }
  end)
end

return {
  {
    'FabijanZulj/blame.nvim',
    dependencies = {
      'folke/which-key.nvim',
    },
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
    'esmuellert/codediff.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    cmd = 'CodeDiff',
    opts = {
      keymaps = {
        view = {
          next_hunk = ']g',
          prev_hunk = '[g',
        },
      },
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
        map('n', '<leader>hd', function()
          vim.cmd [[CodeDiff file HEAD]]
        end, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          vim.cmd [[CodeDiff]]
        end, { desc = 'git [d]iff all changes against index' })
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
    keys = {
      -- stylua: ignore start
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "[B]ranches" },
      { "<leader>gl", function() Snacks.picker.git_log {
        confirm = function(picker, item)
          picker:close()
          walk_in_codediff(item.commit)
        end,
      } end, desc = "[L]og" },
      { "<leader>gL", function() Snacks.picker.git_log_line {
        confirm = function(picker, item)
          picker:close()
          walk_in_codediff(item.commit)
        end,
      } end, desc = "Log [L]ine" },

      -- Search in Git history
      { "<leader>ge", function() git_pickaxe { global = false } end, desc = "S[e]arch (buffer)" },
      { "<leader>gE", function() git_pickaxe { global = true } end, desc = "S[e]arch (global)" },

      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "[S]tatus" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "[S]tash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "[D]iff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file {
        confirm =  function(picker, item)
          picker:close()
          walk_in_codediff(item.commit)
        end,
      } end, desc = "Log [F]ile" },
      -- gh
      { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub [i]ssues (open)" },
      { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub [I]ssues (all)" },
      { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub [p]R's (open)" },
      { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub [P]R's (all)" },
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
      { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazy[g]it', },
      -- stylua: ignore end
    },
    opts = {
      lazygit = { enabled = true },
    },
  },
}

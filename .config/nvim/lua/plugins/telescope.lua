return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    'folke/trouble.nvim',
  },
  config = function()
    local open_with_trouble = require('trouble.sources.telescope').open
    local add_to_trouble = require('trouble.sources.telescope').add

    local fzf_opts = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = 'smart_case', -- or "ignore_case" or "respect_case" the default case_mode is "smart_case"
    }

    require('telescope').setup {
      pickers = {
        find_files = {
          hidden = true,
        },
        buffer = {
          mappings = {
            i = {
              ['<C-d>'] = 'delete_buffer',
            },
            n = {
              ['<C-d>'] = 'delete_buffer',
            },
          },
        },
        -- Manually set sorter, for some reason not picked up automatically
        lsp_dynamic_workspace_symbols = {
          sorter = require('telescope').extensions.fzf.native_fzf_sorter(fzf_opts),
        },
      },
      defaults = {
        mappings = {
          i = {
            -- FIXME: which_key doesn't get updated with custom keybinds
            ['<C-7>'] = 'which_key',
            ['<C-x>'] = open_with_trouble,
            ['<C-X>'] = add_to_trouble,
            ['<C-t>'] = 'file_tab',
            ['<C-s>'] = 'select_horizontal',
          },
          n = {
            ['<C-x>'] = open_with_trouble,
            ['<C-X>'] = add_to_trouble,
            ['<C-t>'] = 'file_tab',
            ['<C-s>'] = 'select_horizontal',
          },
        },
        file_ignore_patterns = {
          '^.git/',
          '^node_modules/',
          '^build/',
          '^coverage/',
          '%.lock',
          '%.snap',
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--ignore-file',
          '.gitignore',
        },
      },
      -- pickers = {}
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
        extensions = {
          fzf = fzf_opts,
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    -- vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sg', require('config.telescope').live_multigrep, { desc = '[S]earch by Multi[G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', function()
      builtin.buffers {
        only_cwd = true,
        sort_lastused = true,
      }
    end, { desc = '[ ] Find existing buffers' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}

local ai_whichkey = function(opts)
  local objects = {
    { ' ', desc = 'whitespace' },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { '(', desc = '() block' },
    { ')', desc = '() block with ws' },
    { '<', desc = '<> block' },
    { '>', desc = '<> block with ws' },
    { '?', desc = 'user prompt' },
    { 'U', desc = 'use/call without dot' },
    { '[', desc = '[] block' },
    { ']', desc = '[] block with ws' },
    { '_', desc = 'underscore' },
    { '`', desc = '` string' },
    { 'a', desc = 'argument' },
    { 'b', desc = ')]} block' },
    { 'c', desc = 'class', ts = true },
    { 'd', desc = 'digit(s)' },
    { 'e', desc = 'CamelCase / snake_case' },
    { 'm', desc = 'method', ts = true },
    { 'g', desc = 'entire file' },
    { 'i', desc = 'indent' },
    { 'o', desc = 'block, conditional, loop', ts = true },
    { 'q', desc = 'quote `"\'' },
    { 'r', desc = 'return', ts = true },
    { 'R', desc = 'regex', ts = true },
    { 't', desc = 'tag' },
    { 'u', desc = 'use/call' },
    { '{', desc = '{} block' },
    { '}', desc = '{} with ws' },
  }

  local ret = { mode = { 'o', 'x' } }
  ---@type table<string, string>
  local mappings = vim.tbl_extend('force', {}, {
    around = 'a',
    inside = 'i',
    around_next = 'an',
    inside_next = 'in',
    around_last = 'al',
    inside_last = 'il',
  }, opts.mappings or {})
  mappings.goto_left = nil
  mappings.goto_right = nil

  for name, prefix in pairs(mappings) do
    name = name:gsub('^around_', ''):gsub('^inside_', '')
    ret[#ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      -- keeping this, it seems to work but docs say it shouldn't, so i don't know
      -- if prefix:sub(2, 2) == 'n' or prefix:sub(2, 2) == 'l' then
      --   if obj.ts then
      --     do
      --       break
      --     end -- treesitter gen specs can't be chained with next/last so we continue
      --   end
      -- end
      if prefix:sub(1, 1) == 'i' then
        desc = desc:gsub(' with ws', '')
      end
      ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
    end
  end
  require('which-key').add(ret, { notify = false })
end

return {
  'echasnovski/mini.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    local ai = require 'mini.ai'
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    local ai_opts = {
      n_liness = 500,
      custom_textobjects = {
        o = ai.gen_spec.treesitter { -- code block
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        },
        m = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' }, -- method/function
        c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' }, -- class
        t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
        d = { '%f[%d]%d+' }, -- digits
        e = { -- Word with case
          { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
          '^().*()$',
        },
        u = ai.gen_spec.function_call(), -- u for "Usage"
        U = ai.gen_spec.function_call { name_pattern = '[%w_]' }, -- without dot in function name
        r = ai.gen_spec.treesitter { a = '@return.outer', i = '@return.inner' }, -- scope
        R = ai.gen_spec.treesitter { a = '@regex.outer', i = '@regex.inner' }, -- scope
      },
    }

    ai.setup(ai_opts)
    ai_whichkey(ai_opts)

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - gsaiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - gsd'   - [S]urround [D]elete [']quotes
    -- - gsr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup {
      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`

        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
    }

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    -- local statusline = require 'mini.statusline'
    -- statusline.setup {
    --   -- set use_icons to true if you have a Nerd Font
    --   use_icons = vim.g.have_nerd_font,
    --   content = {
    --     active = function()
    --       local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
    --       local git = statusline.section_git { trunc_width = 40 }
    --       local diff = statusline.section_diff { trunc_width = 75 }
    --       local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
    --       local lsp = statusline.section_lsp { trunc_width = 75 }
    --       local filename = statusline.section_filename { trunc_width = 140 }
    --       local fileinfo = statusline.section_fileinfo { trunc_width = 120 }
    --       local search = statusline.section_searchcount { trunc_width = 75 }
    --       local macro = vim.g.macro_recording
    --
    --       return MiniStatusline.combine_groups {
    --         { hl = mode_hl, strings = { mode } },
    --         { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
    --         { hl = '', strings = { '%<' } }, -- Mark general truncate point
    --         '%=', -- End left alignment, start center alignment
    --         { hl = 'MiniStatuslineFilename', strings = { filename } },
    --         '%=', -- End center alignment, start right alignment
    --         { hl = 'MiniStatuslineFilename', strings = { macro } },
    --         { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
    --         { hl = mode_hl, strings = { search, '%2l:%-2v' } },
    --       }
    --     end,
    --   },
    -- }
    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}

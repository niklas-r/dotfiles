local M = {}

--- Semgrep ranges are 1-based lines and 1-based columns (end exclusive);
--- snacks positions are 1-based lines with 0-based columns.
--- Realpath resolves symlinks; unsaved or missing files fall back to the absolute path.
local function canonical(name)
  local abs = vim.fn.fnamemodify(name, ':p')
  return vim.fs.normalize(vim.uv.fs_realpath(abs) or abs)
end

--- Exact name lookup for loaded file buffers, built once per finder call:
--- vim.fn.bufnr() treats the path as a pattern, so cfg.py.bak can match cfg.py.
---@return fun(path: string): integer?
local function buf_resolver()
  local by_name = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(b)
    if vim.api.nvim_buf_is_loaded(b) and name ~= '' and vim.bo[b].buftype ~= 'terminal' then
      by_name[canonical(name)] = by_name[canonical(name)] or b
    end
  end
  local cache = {}
  return function(path)
    if cache[path] == nil then
      cache[path] = by_name[canonical(path)] or false
    end
    return cache[path] or nil
  end
end

---@param finding SemgrepFinding
---@param buf integer?
---@return snacks.picker.Item
local function to_item(finding, buf)
  return {
    text = table.concat({ vim.diagnostic.severity[finding.severity] or '', finding.check_id, finding.path, finding.message }, ' '),
    file = finding.path,
    buf = buf,
    pos = { finding.start.line, finding.start.col - 1 },
    end_pos = { finding.finish.line, math.max(finding.finish.col - 1, 0) },
    severity = finding.severity,
    item = finding,
  }
end

---@type snacks.picker.Config
M.source = {
  title = 'Semgrep findings',
  preview = 'file',
  finder = function(_, ctx)
    local items = {}
    local resolve = buf_resolver()
    for _, finding in ipairs(require('semgrep.store').all) do
      items[#items + 1] = to_item(finding, resolve(finding.path))
    end
    -- store.all is rebuilt in hash order after a fix, so sort for a stable list.
    table.sort(items, function(a, b)
      if a.file ~= b.file then
        return a.file < b.file
      end
      if a.pos[1] ~= b.pos[1] then
        return a.pos[1] < b.pos[1]
      end
      if a.pos[2] ~= b.pos[2] then
        return a.pos[2] < b.pos[2]
      end
      if a.item.check_id ~= b.item.check_id then
        return a.item.check_id < b.item.check_id
      end
      if a.end_pos[1] ~= b.end_pos[1] then
        return a.end_pos[1] < b.end_pos[1]
      end
      return a.end_pos[2] < b.end_pos[2]
    end)
    return ctx.filter:filter(items)
  end,
  format = function(item, picker)
    local ret = {}
    local finding = item.item
    vim.list_extend(ret, Snacks.picker.format.severity(item, picker))
    ret[#ret + 1] = { finding.message }
    ret[#ret + 1] = { ' ' }
    ret[#ret + 1] = { ('(%s)'):format(finding.check_id), 'SnacksPickerDiagnosticCode' }
    ret[#ret + 1] = { ' ' }
    if type(finding.fix) == 'string' then
      ret[#ret + 1] = { 'fix', 'SnacksPickerSpecial' }
      ret[#ret + 1] = { ' ' }
    end
    vim.list_extend(ret, Snacks.picker.format.filename(item, picker))
    return ret
  end,
  actions = {
    semgrep_fix = function(picker, item)
      local finding = item and item.item
      if not finding or type(finding.fix) ~= 'string' then
        Snacks.notify.warn 'This semgrep finding has no autofix'
        return
      end
      local buf = vim.fn.bufadd(finding.path)
      vim.fn.bufload(buf)

      local store = require 'semgrep.store'
      local ns = vim.api.nvim_create_namespace 'snacks_semgrep_fix'
      local start_row, start_col = finding.start.line - 1, finding.start.col - 1
      local end_row, end_col = finding.finish.line - 1, math.max(finding.finish.col - 1, 0)

      -- Extmarks carry the other findings' ranges across the edit. Neovim resolves a
      -- mark anywhere in the replaced span by gravity alone, so a sibling that merely
      -- ends where the edit begins needs left gravity to stay put, while one ending
      -- inside or at the end of the edit needs right gravity to follow the new text.
      -- A sibling that partially overlaps the edit, or a zero-width one strictly
      -- inside it, no longer matches anything and is dropped.
      local function before(r1, c1, r2, c2)
        return r1 < r2 or (r1 == r2 and c1 < c2)
      end
      local tracked = {}
      local survivors = {}
      for _, f in ipairs(store.for_path(finding.path)) do
        if f ~= finding then
          local f_start_row, f_start_col = f.start.line - 1, f.start.col - 1
          local f_end_row, f_end_col = f.finish.line - 1, math.max(f.finish.col - 1, 0)
          local intersects = before(f_start_row, f_start_col, end_row, end_col) and before(start_row, start_col, f_end_row, f_end_col)
          local contains = not before(start_row, start_col, f_start_row, f_start_col) and not before(f_end_row, f_end_col, end_row, end_col)
          local zero_width = f_start_row == f_end_row and f_start_col == f_end_col
          local starts_at_edit = f_start_row == start_row and f_start_col == start_col
          -- The same range as the edit matched text that is now gone.
          local same_range = starts_at_edit and f_end_row == end_row and f_end_col == end_col
          if (not intersects or contains) and not (same_range and not zero_width) then
            local ends_before = not before(start_row, start_col, f_end_row, f_end_col)
            local finish_id = vim.api.nvim_buf_set_extmark(buf, ns, f_end_row, f_end_col, { strict = false, right_gravity = not ends_before })
            -- A container sharing a non-empty edit's start must keep its start there, not slide past the new text.
            local start_gravity = not (contains and starts_at_edit and before(start_row, start_col, end_row, end_col))
            tracked[#tracked + 1] = {
              finding = f,
              start_id = zero_width and finish_id or vim.api.nvim_buf_set_extmark(buf, ns, f_start_row, f_start_col, { strict = false, right_gravity = start_gravity }),
              finish_id = finish_id,
            }
          end
        end
      end

      -- Apply the selected finding directly; semgrep's own fix_at_cursor would
      -- re-resolve it by line only and pick the wrong one when two share a line.
      local ok, err = pcall(vim.api.nvim_buf_set_text, buf, start_row, start_col, end_row, end_col, vim.split(finding.fix, '\n', { plain = true }))
      if not ok then
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        Snacks.notify.warn('Failed to apply semgrep fix for ' .. finding.check_id .. ' (' .. tostring(err) .. ')')
        return
      end

      for _, t in ipairs(tracked) do
        local s = vim.api.nvim_buf_get_extmark_by_id(buf, ns, t.start_id, {})
        local e = vim.api.nvim_buf_get_extmark_by_id(buf, ns, t.finish_id, {})
        if s[1] and e[1] and not before(e[1], e[2], s[1], s[2]) then
          t.finding.start = { line = s[1] + 1, col = s[2] + 1 }
          t.finding.finish = { line = e[1] + 1, col = e[2] + 1 }
          t.finding.lnum = s[1]
          survivors[#survivors + 1] = t.finding
        end
      end
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

      store.set_file(finding.path, survivors)
      require('semgrep.scan').set_diagnostics(buf, survivors)
      picker:find()
    end,
  },
  win = {
    input = {
      keys = {
        ['<c-f>'] = { 'semgrep_fix', mode = { 'n', 'i' }, desc = 'Apply semgrep fix' },
      },
    },
    list = {
      keys = {
        ['<c-f>'] = { 'semgrep_fix', desc = 'Apply semgrep fix' },
      },
    },
  },
}

function M.open()
  if #require('semgrep.store').all == 0 then
    Snacks.notify.warn 'No semgrep findings. Run :SemgrepScanWorkspace first'
    return
  end
  Snacks.picker.semgrep()
end

return M

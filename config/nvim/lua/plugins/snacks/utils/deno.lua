local M = {}

--- Run TypeScript/JavaScript code with Deno
--- Shows output inline with virtual text and errors as diagnostics
---@param buf number Buffer handle
function M.run(buf)
  local ns = vim.api.nvim_create_namespace 'snacks_deno'
  buf = buf == 0 and vim.api.nvim_get_current_buf() or buf

  -- Get the lines to run
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local mode = vim.fn.mode()
  local buffer_offset = 0 -- Where the code starts in the buffer (for visual mode)

  if mode:find '[vV]' then
    if mode == 'v' then
      vim.cmd 'normal! v'
    elseif mode == 'V' then
      vim.cmd 'normal! V'
    end
    local from = vim.api.nvim_buf_get_mark(buf, '<')
    local to = vim.api.nvim_buf_get_mark(buf, '>')
    local col_to = math.min(to[2] + 1, #vim.api.nvim_buf_get_lines(buf, to[1] - 1, to[1], false)[1])
    lines = vim.api.nvim_buf_get_text(buf, from[1] - 1, from[2], to[1] - 1, col_to, {})
    buffer_offset = from[1] - 1
    vim.fn.feedkeys('gv', 'nx')
  end

  -- Clear previous diagnostics and extmarks
  local function reset()
    vim.diagnostic.reset(ns, buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
  reset()

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = vim.api.nvim_create_augroup('snacks_deno_run_' .. buf, { clear = true }),
    buffer = buf,
    callback = reset,
  })

  -- Create a temporary file with instrumentation
  local ft = vim.bo[buf].filetype
  local ext = (ft == 'typescript' or ft == 'typescriptreact') and '.ts' or '.js'
  local tmpfile = vim.fn.tempname() .. ext

  -- Instrumentation code to capture line numbers
  local instrumentation = [[
// Snacks.nvim console instrumentation
const __original_log = console.log;
const __original_info = console.info;
const __original_warn = console.warn;
const __original_error = console.error;

function __getCallerLine() {
  const stack = new Error().stack;
  const lines = stack.split('\n');
  // Skip the first 3 lines: Error, __getCallerLine, and the console wrapper
  // The 4th line should be the actual caller
  if (lines.length > 3) {
    const match = lines[3].match(/:(\d+):(\d+)/);
    if (match) {
      return `${match[1]}:${match[2]}`;
    }
  }
  return '0:0';
}

console.log = function(...args) {
  const lineCol = __getCallerLine();
  __original_log(`__LINE__:${lineCol}:`, ...args);
};

console.info = function(...args) {
  const lineCol = __getCallerLine();
  __original_info(`__LINE__:${lineCol}:`, ...args);
};

console.warn = function(...args) {
  const lineCol = __getCallerLine();
  __original_warn(`__LINE__:${lineCol}:`, ...args);
};

console.error = function(...args) {
  const lineCol = __getCallerLine();
  __original_error(`__LINE__:${lineCol}:`, ...args);
};

]]

  local f = io.open(tmpfile, 'w')
  if not f then
    vim.notify('Failed to create temporary file', vim.log.levels.ERROR)
    return
  end
  f:write(instrumentation)
  f:write(table.concat(lines, '\n'))
  f:close()

  -- Count instrumentation lines
  local instrumentation_lines = select(2, instrumentation:gsub('\n', '\n'))

  -- Run deno
  local stdout_lines = {}
  local stderr_lines = {}

  local function on_exit()
    vim.schedule(function()
      -- Parse stderr for errors
      if #stderr_lines > 0 then
        -- Strip ANSI color codes
        local function strip_ansi(str)
          return str:gsub('\27%[[%d;]*m', '')
        end

        local stderr_clean = vim.tbl_map(strip_ansi, stderr_lines)
        local stderr = table.concat(stderr_clean, '\n')

        -- Parse Deno error format: "at file:///path:line:col"
        -- Find the line number from the stack trace
        local error_line, error_col
        local error_msg = ''

        for i, line_content in ipairs(stderr_clean) do
          -- Look for the "at file://" line with our temp file
          local line_num, col_num = line_content:match(tmpfile:gsub('([^%w])', '%%%1') .. ':(%d+):(%d+)')
          if line_num then
            error_line = tonumber(line_num)
            error_col = tonumber(col_num)
            -- Build error message from the previous lines
            error_msg = table.concat(vim.list_slice(stderr_clean, 1, math.min(i - 1, 3)), '\n')
            break
          end
        end

        if error_line then
          -- Map temp file line back to buffer line
          local adjusted_line = error_line - instrumentation_lines + buffer_offset - 1
          vim.diagnostic.set(ns, buf, {
            {
              col = error_col and (error_col - 1) or 0,
              lnum = adjusted_line,
              message = error_msg,
              severity = vim.diagnostic.severity.ERROR,
            },
          })
        else
          -- If we couldn't parse line numbers, show error in notification
          Snacks.notify.error(stderr, { title = 'Deno Error' })
        end
      end

      -- Display stdout as virtual text
      if #stdout_lines > 0 then
        local output_by_line = {} ---@type table<number, string[]>

        for _, line in ipairs(stdout_lines) do
          if line ~= '' then
            -- Try to extract line number from our instrumentation
            local line_num, col_num, content = line:match '^__LINE__:(%d+):(%d+): (.*)$'
            if line_num then
              -- Map temp file line back to buffer line
              -- temp file line is 1-indexed, buffer line needs to be 0-indexed
              local source_line = tonumber(line_num) - instrumentation_lines + buffer_offset - 1

              output_by_line[source_line] = output_by_line[source_line] or {}
              table.insert(output_by_line[source_line], content)
            else
              -- Fallback: output without line info goes at the end
              local last_line = buffer_offset + #lines - 1
              output_by_line[last_line] = output_by_line[last_line] or {}
              table.insert(output_by_line[last_line], line)
            end
          end
        end

        -- Display virtual lines at each source line
        local buf_line_count = vim.api.nvim_buf_line_count(buf)
        for line_num, outputs in pairs(output_by_line) do
          -- Ensure line number is valid
          if line_num >= 0 and line_num < buf_line_count then
            local virt_lines = {}
            for _, out in ipairs(outputs) do
              table.insert(virt_lines, { { ' ↳ ', 'DiagnosticVirtualLinesInfo' }, { out, 'DiagnosticVirtualLinesInfo' } })
            end
            vim.api.nvim_buf_set_extmark(buf, ns, line_num, 0, {
              virt_lines = virt_lines,
            })
          end
        end
      end

      -- Clean up temp file
      vim.fn.delete(tmpfile)
    end)
  end

  -- Start the job
  vim.fn.jobstart({ 'deno', 'run', '--allow-all', tmpfile }, {
    on_stdout = function(_, data)
      if data then
        -- Filter out empty trailing string that jobstart adds
        for i, line in ipairs(data) do
          if i < #data or line ~= '' then
            table.insert(stdout_lines, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        -- Filter out empty trailing string that jobstart adds
        for i, line in ipairs(data) do
          if i < #data or line ~= '' then
            table.insert(stderr_lines, line)
          end
        end
      end
    end,
    on_exit = on_exit,
  })
end

return M

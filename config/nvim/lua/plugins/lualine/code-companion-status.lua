local M = require('lualine.component'):extend()

local CLEAR_TIMEOUT_NS = 2000000000 -- 2 seconds in nanoseconds

M.event_map = {
  ['CodeCompanionRequestStarted'] = " Let's gooo",
  ['CodeCompanionRequestStreaming'] = " Vibin'",
  ['CodeCompanionRequestFinished'] = ' We done fr',
}

M.processing = false
M.current_event = nil
M.spinner_index = 1
M.clear_time = nil

local spinner_symbols = require('utils.spinners').FourHigh
local spinner_symbols_len = #spinner_symbols

local FINISH_EVENTS = {
  'CodeCompanionRequestFinished',
}

local PROCESSING_EVENTS = {
  'CodeCompanionRequestStarted',
  'CodeCompanionRequestStreaming',
}

-- Helper function to check if event is in a list
local function is_event_in_list(event, event_list)
  for _, e in ipairs(event_list) do
    if e == event then
      return true
    end
  end
  return false
end

function M:init(options)
  M.super.init(self, options)

  local group = vim.api.nvim_create_augroup('CodeCompanionHooks', {})

  vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = 'CodeCompanionRequest*',
    group = group,
    callback = function(request)
      self.current_event = request.match

      if is_event_in_list(request.match, PROCESSING_EVENTS) then
        self.processing = true
        self.clear_time = nil
      elseif is_event_in_list(request.match, FINISH_EVENTS) then
        self.processing = false
        self.clear_time = vim.uv.hrtime() + CLEAR_TIMEOUT_NS
      end
    end,
  })
end

-- Update spinner animation
local function get_next_spinner()
  M.spinner_index = (M.spinner_index % spinner_symbols_len) + 1
  return spinner_symbols[M.spinner_index]
end

function M:update_status()
  -- Check if we should clear the message
  if self.clear_time and vim.uv.hrtime() >= self.clear_time then
    self.current_event = nil
    self.clear_time = nil
    return nil
  end

  -- Return status message with optional spinner
  if self.current_event and self.event_map[self.current_event] then
    local message = self.event_map[self.current_event]
    return self.processing and (message .. ' ' .. get_next_spinner()) or message
  end

  return nil
end

return M

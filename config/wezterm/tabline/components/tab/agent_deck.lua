local wez = require 'wezterm' ---@type Wezterm
local agent_deck = wez.plugin.require 'https://github.com/Eric162/wezterm-agent-deck' ---@type AgentDeck

local priority = {
  waiting = 1,
  working = 2,
  idle = 3,
  inactive = 4,
}

return {
  default_opts = {
    icon = { agent_deck.get_status_icon 'inactive' },
  },
  update = function(tab, opts)
    local highest_status = 'inactive'
    local agent_count = 0

    for _, pane in ipairs(tab.panes or {}) do
      local agent_state = agent_deck.get_agent_state(pane.pane_id)
      if agent_state then
        agent_count = agent_count + 1

        local status = agent_state.status or 'inactive'
        if priority[status] < priority[highest_status] then
          highest_status = status
        end
      end
    end

    if agent_count == 0 then
      return nil
    end

    opts.icon = {
      agent_deck.get_status_icon(highest_status),
      color = { fg = agent_deck.get_status_color(highest_status) },
    }

    if agent_count > 1 then
      local old_padding = opts.padding or {}

      opts.padding = {
        left = old_padding.left or 0,
        right = math.max(old_padding.right or 0, 1),
      }
    end

    return agent_count > 1 and tostring(agent_count) or ''
  end,
}

local wez = require 'wezterm' ---@type Wezterm
local agent_deck = wez.plugin.require 'https://github.com/Eric162/wezterm-agent-deck' ---@type AgentDeck

local statuses = { 'waiting', 'working', 'idle' }

local function get_primary_status(counts)
  for _, status in ipairs(statuses) do
    if (counts[status] or 0) > 0 then
      return status
    end
  end

  return 'inactive'
end

return {
  default_opts = {
    icon = { agent_deck.get_status_icon 'inactive' },
  },
  update = function(window, opts)
    local counts = {
      waiting = 0,
      working = 0,
      idle = 0,
    }

    for _, tab in ipairs(window:mux_window():tabs()) do
      for _, pane in ipairs(tab:panes()) do
        local agent_state = agent_deck.update_pane(pane)
        if agent_state and counts[agent_state.status] ~= nil then
          counts[agent_state.status] = counts[agent_state.status] + 1
        end
      end
    end

    local total_agents = counts.waiting + counts.working + counts.idle
    if total_agents == 0 then
      return nil
    end

    local primary_status = get_primary_status(counts)
    opts.icon = {
      agent_deck.get_status_icon(primary_status),
      color = { fg = agent_deck.get_status_color(primary_status) },
    }

    local parts = {}
    for _, status in ipairs(statuses) do
      if counts[status] > 0 then
        parts[#parts + 1] = counts[status] .. status:sub(1, 1)
      end
    end

    return table.concat(parts, ' ')
  end,
}

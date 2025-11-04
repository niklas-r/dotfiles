-- To get Hammerspoon to read this config file instead of ~/.hammerspoon/init.lua
-- run this command (would be nice if this was automated but I don't have anough gray
-- hair for Nix, yet.)
--
-- defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
-- @require hammerspoon

-- Global app keybinds

local MEH_MODS = { 'ctrl', 'shift', 'alt' }
local HYPER_MODS = { 'cmd' }

for _, v in pairs(MEH_MODS) do
  table.insert(HYPER_MODS, v)
end

local mappings = {
  { MEH_MODS, '1', '1Password' },
  { MEH_MODS, 'A', 'Arc' },
  { MEH_MODS, 'B', 'Bitwarden' },
  { MEH_MODS, 'C', 'Calendar' },
  { MEH_MODS, 'D', 'Discord' },
  { MEH_MODS, 'F', 'Finder' },
  { MEH_MODS, 'M', 'Mail' },
  { MEH_MODS, 'O', 'Microsoft Outlook' }, -- Sigh...
  { HYPER_MODS, 'O', 'Obsidian' },
  { MEH_MODS, 'P', 'Postman' },
  { MEH_MODS, 'S', 'Signal' },
  { MEH_MODS, 'T', 'Wezterm' },
  { HYPER_MODS, 'T', 'Microsoft Teams' }, -- Sigh...
}

for _, mapping in pairs(mappings) do
  local mods, key, app = table.unpack(mapping)
  hs.hotkey
    .new(mods, key, function()
      hs.application.launchOrFocus(app)
    end)
    :enable()
end

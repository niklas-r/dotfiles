---@class CodeCompanion.PromptLibrary.Opts
---@field index number The index/order of the prompt in the library
---@field is_default boolean Whether this is a default prompt
---@field is_slash_cmd? boolean Whether this prompt can be used as a slash command
---@field user_prompt? boolean Whether this prompt requires user input
---@field modes? string[] The Neovim modes this prompt is available in (e.g., {"v"})
---@field short_name? string Short name/alias for the prompt
---@field auto_submit? boolean Whether to automatically submit the prompt
---@field placement? string Where to place the result (e.g., "new")
---@field stop_context_insertion? boolean Whether to stop context insertion
---@field ignore_system_prompt? boolean Whether to ignore the system prompt

---@class CodeCompanion.PromptLibrary.PromptOpts
---@field visible? boolean Whether the prompt is visible in the chat
---@field tag? string Optional tag for the prompt
---@field auto_submit? boolean Whether to automatically submit this prompt
---@field contains_code? boolean Whether the prompt contains code
---@field show_line_numbers? boolean Whether to show line numbers in code blocks

---@class CodeCompanion.PromptLibrary.Reference
---@field type string The type of reference (e.g., "file")
---@field path string[] Array of file paths

---@class CodeCompanion.PromptLibrary.Prompt
---@field role "system" | "llm" | "user" The role of the prompt (system/user/llm)
---@field content string|fun(context: table): string The content of the prompt or function that generates it
---@field opts? CodeCompanion.PromptLibrary.PromptOpts Options for this specific prompt
---@field name? string Optional name for the prompt
---@field condition? fun(): boolean Optional condition function to determine if prompt should be used
---@field repeat_until? fun(chat: table): boolean Optional function to determine if prompt should be repeated

---@class CodeCompanion.PromptLibrary.Item
---@field strategy "chat" | "inline" | "workflow" The strategy to use (e.g., "chat", "inline", "workflow")
---@field description string Description of what the prompt does
---@field opts CodeCompanion.PromptLibrary.Opts Options for the prompt library item
---@field prompts (CodeCompanion.PromptLibrary.Prompt|CodeCompanion.PromptLibrary.Prompt[])[] Array of prompts or prompt groups
---@field references? CodeCompanion.PromptLibrary.Reference[] Optional array of references

local M = {}

M['Beast mode'] = require 'plugins.code-companion.prompts.beast_mode'
M['Get to work'] = require 'plugins.code-companion.prompts.cancer'
M['context7'] = require 'plugins.code-companion.prompts.context7'

return M

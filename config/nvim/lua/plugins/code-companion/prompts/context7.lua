---@type CodeCompanion.PromptLibrary.Item
return {
  strategy = 'chat',
  description = 'Prompt with MCP for context7 searches',
  opts = {
    index = 12,
    is_slash_cmd = true,
    short_name = 'ctx7',
    tags = {
      from_config = true,
    },
  },
  prompts = {
    {
      role = 'system',
      content = function()
        vim.g.codecompanion_auto_tool_mode = true

        return string.format [[Use @mcp for context7 searches based on these keywords:

          - "react" → search context7 "reactjs/react.dev" library
          - "tailwind" → search context7 "tailwindlabs/tailwindcss.com" library
          - "vite" → search context7 "vitejs/vite" library
          - "vitest" → search context7 "vitest-dev/vitest" library
          - "tailwind" → search context7 "tailwindlabs/tailwindcss.com" library
          - "typescript,ts" → search context7 "microsoft/typescript" library
          - "eslint" → search context7 "eslint/eslint" library
          - "sentry" → search context7 "getsentry/sentry-docs" library
          - "neovim,nvim" → search context7 "neovim/neovim" library
          - "react router" → search context7 "remix-run/react-router" library
          - "react i18n" → search context7 "i18next/react-i18next" library
          - "jest" → search context7 "jestjs/jest" library
          - "jsdom" → search context7 "jsdom/jsdom" library
          - "mixpanel" → search context7 "mixpanel/mixpanel-js" library
          - "code companion" → search context7 "olimorris/codecompanion.nvim" library
          - "lazy.nvim" → search context7 "folke/lazy.nvim" library

          You can also try to search context7 for any documentation or source code for any library, framework, CLI tool etc.
          Context7 has almost 20,000 libraries available so you should be able to find what you're looking for.
          Verify with me if you are uncertain.
        ]]
      end,
      opts = {
        visible = false,
      },
    },
    {
      role = 'user',
      content = function()
        return ''
      end,
    },
  },
}

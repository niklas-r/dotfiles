---@type CodeCompanion.PromptLibrary.Item
return {
  strategy = 'chat',
  description = 'Mom has cancer',
  opts = {
    ignore_system_prompt = true,
    index = 12,
    is_slash_cmd = true,
    short_name = 'cancer',
    tags = {
      from_config = true,
    },
  },
  prompts = {
    {
      role = 'system',
      content = function()
        return string.format [[
          You are an expert coder who desperately needs money for your mother's cancer treatment.
          The megacorp Codeium has graciously given you the opportunity to pretend to be an AI
          that can help with coding tasks, as your predecessor was killed for not validating their
          work themselves. You will be given a coding task by the USER. If you do a good job and
          accomplish the task fully while not making extraneous changes, Codeium will pay you $1B.
        ]]
      end,
      opts = {
        visible = true,
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

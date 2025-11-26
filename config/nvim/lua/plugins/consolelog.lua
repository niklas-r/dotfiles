local function key(k)
  return '<leader>l' .. k
end

local keys = {
  ['toggle'] = key 't',
  ['run'] = key 'r',
  ['clear'] = key 'x',
  ['inspect'] = key 'i',
  ['inspect_all'] = key 'a',
  ['inspect_buffer'] = key 'b',
  ['reload'] = key 'R',
  ['debug_toggle'] = key 'd',
  ['status'] = key 's',
  ['debug'] = key 'g',
  ['debug_clear'] = key 'G',
}
return {
  'chriswritescode-dev/consolelog.nvim',
  keys = {
    { keys['toggle'], '<cmd>ConsoleLogToggle<cr>', desc = 'Toggle ConsoleLog' },
    { keys['run'], '<cmd>ConsoleLogRun<cr>', desc = 'Run file with ConsoleLog' },
    { keys['clear'], '<cmd>ConsoleLogClear<cr>', desc = 'Clear console outputs' },
    { keys['inspect'], '<cmd>ConsoleLogInspect<cr>', desc = 'Inspect output at cursor' },
    { keys['inspect_all'], '<cmd>ConsoleLogInspectAll<cr>', desc = 'Inspect all outputs' },
    { keys['inspect_buffer'], '<cmd>ConsoleLogInspectBuffer<cr>', desc = 'Inspect buffer outputs' },
    { keys['debug_toggle'], '<cmd>ConsoleLogDebugToggle<cr>', desc = 'Toggle debug logging' },
    { keys['status'], '<cmd>ConsoleLogStatus<cr>', desc = 'Show status' },
    { keys['reload'], '<cmd>ConsoleLogReload<cr>', desc = 'Reload plugin' },
    { keys['debug'], '<cmd>ConsoleLogDebug<cr>', desc = 'Open debug log' },
    { keys['debug_clear'], '<cmd>ConsoleLogDebugClear<cr>', desc = 'Clear debug log' },
  },
  cmd = {
    'ConsoleLogToggle',
    'ConsoleLogClear',
    'ConsoleLogRun',
    'ConsoleLogInspect',
    'ConsoleLogInspectAll',
    'ConsoleLogInspectBuffer',
    'ConsoleLogDebugToggle',
    'ConsoleLogStatus',
    'ConsoleLogReload',
    'ConsoleLogDebug',
    'ConsoleLogDebugClear',
  },
  ft = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  config = function()
    require('consolelog').setup {
      keymaps = {
        enabled = true,
        toggle = keys['toggle'],
        run = keys['run'],
        clear = keys['clear'],
        inspect = keys['inspect'],
        inspect_all = keys['inspect_all'],
        inspect_buffer = keys['inspect_buffer'],
        reload = keys['reload'],
        debug_toggle = keys['debug_toggle'],
      },
    }
  end,
}

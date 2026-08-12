return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    copilot_node_command = 'node',
    filetypes = {
      markdown = true,
      yaml = true,
      ['*'] = true,
    },
  },
}

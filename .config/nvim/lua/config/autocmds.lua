-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_user_command('LspCopilotSignIn', function()
  local client = vim.lsp.get_clients({ name = 'copilot' })[1]

  if not client then
    vim.notify('Copilot LSP is not running', vim.log.levels.ERROR)
    return
  end

  ---@diagnostic disable-next-line: param-type-mismatch -- Copilot-specific LSP method
  client:request('signIn', vim.empty_dict(), function(err, result)
    if err then
      vim.notify(vim.inspect(err), vim.log.levels.ERROR)
      return
    end

    vim.schedule(function()
      vim.notify('Copilot code: ' .. result.userCode)

      vim.fn.setreg('+', result.userCode)

      client:request('workspace/executeCommand', {
        command = result.command.command,
        arguments = result.command.arguments or {},
      })
    end)
  end)
end, {})

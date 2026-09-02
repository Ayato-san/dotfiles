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

vim.api.nvim_create_user_command('FormatProject', function()
  local conform = require('conform')
  local files = vim.fn.systemlist('git ls-files')

  if vim.v.shell_error ~= 0 then
    vim.notify('FormatProject: not inside a Git repository', vim.log.levels.ERROR)
    return
  end

  local formatted = 0
  local skipped = 0
  local failed = {}

  for _, file in ipairs(files) do
    if vim.fn.filereadable(file) == 1 then
      local bufnr = vim.fn.bufadd(file)
      vim.fn.bufload(bufnr)

      local formatters = conform.list_formatters(bufnr)

      if #formatters == 0 then
        skipped = skipped + 1
      else
        local ok, err = pcall(function()
          conform.format({
            bufnr = bufnr,
            async = false,
            lsp_format = 'fallback',
            quiet = true,
          })

          if vim.bo[bufnr].modified then
            vim.api.nvim_buf_call(bufnr, function()
              vim.cmd('silent write')
            end)
          end
        end)

        if ok then
          formatted = formatted + 1
        else
          table.insert(failed, file .. ': ' .. tostring(err))
        end
      end

      if vim.api.nvim_buf_is_valid(bufnr) and vim.fn.buflisted(bufnr) == 0 then
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
      end
    end
  end

  local msg = ('FormatProject: %d formatted, %d skipped, %d failed'):format(formatted, skipped, #failed)

  if #failed > 0 then
    vim.notify(msg .. '\n\n' .. table.concat(failed, '\n'), vim.log.levels.WARN)
  else
    vim.notify(msg, vim.log.levels.INFO)
  end
end, {
  desc = 'Format all Git-tracked files with Conform',
})

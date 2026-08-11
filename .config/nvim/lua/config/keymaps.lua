-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = false })
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = false })

-- Focus/Unfocus Explorer with <leader>fe
vim.keymap.set('n', '<leader>fe', function()
  local current_win = vim.api.nvim_get_current_win()
  local explorer_win = nil

  -- Scan windows to find the Snacks Explorer pane
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft and ft:find('snacks_picker') then
      explorer_win = win
      break
    end
  end

  if not explorer_win or not vim.api.nvim_win_is_valid(explorer_win) then
    -- Explorer is closed -> Open it
    Snacks.explorer()
  elseif current_win == explorer_win then
    -- Cursor is IN the Explorer -> Switch focus back to Code Editor
    vim.cmd('wincmd p')
  else
    -- Explorer is open on side -> Jump cursor INTO Explorer
    vim.api.nvim_set_current_win(explorer_win)
  end
end, { desc = 'Toggle Explorer Focus' })

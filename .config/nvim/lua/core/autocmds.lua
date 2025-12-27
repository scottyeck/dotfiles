-- Commands and autocommands

vim.api.nvim_create_user_command('ReloadConfig', 'source $MYVIMRC', {})

-- Debug command to check diagnostics
vim.api.nvim_create_user_command('CheckDiagnostics', function()
  local diags = vim.diagnostic.get(0)
  local eslint_diags = {}
  local ts_diags = {}
  for _, diag in ipairs(diags) do
    if diag.source == "eslint" or (diag.code and tostring(diag.code):match("import")) then
      table.insert(eslint_diags, diag)
    elseif diag.source == "typescript" or diag.source == "ts" then
      table.insert(ts_diags, diag)
    end
  end
  vim.notify(string.format("Total diagnostics: %d, TypeScript: %d, ESLint/import: %d", #diags, #ts_diags, #eslint_diags), vim.log.levels.INFO)
  if #eslint_diags > 0 then
    for _, diag in ipairs(eslint_diags) do
      vim.notify(string.format("  ESLint Line %d: %s (%s)", diag.lnum + 1, diag.message, diag.code or "no code"), vim.log.levels.INFO)
    end
  end
  if #ts_diags > 0 then
    for _, diag in ipairs(ts_diags) do
      vim.notify(string.format("  TypeScript Line %d: %s (%s)", diag.lnum + 1, diag.message, diag.code or "no code"), vim.log.levels.INFO)
    end
  end
end, {})

-- Command to check active LSP clients
vim.api.nvim_create_user_command('CheckLSPClients', function()
  local clients = vim.lsp.get_active_clients()
  local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
  vim.notify(string.format("Active clients: %d, Buffer clients: %d", #clients, #buf_clients), vim.log.levels.INFO)
  for _, client in ipairs(buf_clients) do
    vim.notify(string.format("  - %s (id: %d)", client.name, client.id), vim.log.levels.INFO)
  end
end, {})

local group = vim.api.nvim_create_augroup('user_cmds', { clear = true })

-- Highlight on yank
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

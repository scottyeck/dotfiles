-- Fallbacks for when LSP hover (K) comes back empty - see lua/core/ruby_docs.lua
local docs = require('core.ruby_docs')

local function map(mode, lhs, opts, desc)
  vim.keymap.set(mode, lhs, function()
    if mode == 'x' then
      -- leave visual mode first so '< and '> are set
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
    end
    docs.explain(vim.tbl_extend('force', opts, { visual = mode == 'x' }))
  end, { buffer = true, desc = desc })
end

vim.keymap.set('n', 'gK', docs.lookup, { buffer = true, desc = 'Ruby: find method defs + docs' })
map('n', '<leader>K', {}, 'Ruby: explain with Claude (sidebar)')
map('x', '<leader>K', {}, 'Ruby: explain selection with Claude (sidebar)')
map('n', '<leader>kc', { chat = true }, 'Ruby: explain in a Claude Code tmux split')
map('x', '<leader>kc', { chat = true }, 'Ruby: explain selection in a Claude Code tmux split')

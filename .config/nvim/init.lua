-- Personal nvim config
-- @scottyeck - <scott.eckenthal@gmail.com>

-- Set <space> as the leader key
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load core configuration
require('core.options')
require('core.keymaps')
require('core.autocmds')
require('core.commands.note')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/
require('lazy').setup('plugins', {
  -- Lazy.nvim options
  change_detection = {
    notify = false,
  },
})

-- Format on save for JS/TS files (must be after lazy.setup)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function(args)
    local bufnr = args.buf

    -- Run ESLint autofix via null-ls
    vim.lsp.buf.format({
      bufnr = bufnr,
      filter = function(client)
        return client.name == "null-ls"
      end,
      async = false,
    })

    -- Run Prettier
    local ok, prettier = pcall(require, "prettier")
    if ok then
      prettier.format()
    end
  end,
})

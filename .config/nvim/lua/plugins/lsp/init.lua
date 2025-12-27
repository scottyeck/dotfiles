-- LSP configuration hub
-- Mason and shared LSP utilities

local M = {}

-- Set up LSP attach handler for keybindings (shared across all LSP servers)
local lsp_attach_group = vim.api.nvim_create_augroup('lsp-attach', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_attach_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    local bufnr = event.buf

    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    -- Keybindings
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
    map(']a', vim.diagnostic.goto_next, '[N]ext Problem')
    map('[a', vim.diagnostic.goto_prev, '[P]revious Problem')
    map('<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, '[F]ormat document')

    -- Format on save for Ruby files
    if client.name == 'ruby_lsp' and client.supports_method(vim.lsp.protocol.Methods.textDocument_formatting) then
      local format_group = vim.api.nvim_create_augroup('ruby-format-on-save', { clear = true })
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = format_group,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

-- Return all LSP-related plugin specs
return {
  -- Mason: LSP server installer
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
      -- Auto-install LSP servers
      local mason_registry = require('mason-registry')
      mason_registry.refresh(function()
        if not mason_registry.is_installed('ruby-lsp') then
          local ruby_lsp = mason_registry.get_package('ruby-lsp')
          ruby_lsp:install()
        end
        if not mason_registry.is_installed('typescript-language-server') then
          local tsserver = mason_registry.get_package('typescript-language-server')
          tsserver:install()
        end
        if not mason_registry.is_installed('eslint-lsp') then
          local eslint_lsp = mason_registry.get_package('eslint-lsp')
          eslint_lsp:install()
        end

        -- Set up LSP servers after Mason is ready
        require('plugins.lsp.ruby').setup()
        require('plugins.lsp.typescript').setup()
      end)

      -- Also try to set up immediately (in case Mason is already ready)
      vim.defer_fn(function()
        if pcall(require, 'mason-registry') then
          require('plugins.lsp.ruby').setup()
          require('plugins.lsp.typescript').setup()
        end
      end, 1000)
    end,
  },

  -- ESLint via null-ls (import from sibling file)
  require('plugins.lsp.eslint'),
}

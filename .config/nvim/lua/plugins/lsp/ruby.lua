-- Ruby LSP configuration
-- Uses rbenv shims - ensure ruby-lsp gem is installed for your Ruby version
local M = {}

local function get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok then
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
  end
  return capabilities
end

function M.setup()
  vim.lsp.config('ruby_lsp', {
    cmd = { 'ruby-lsp' },
    filetypes = { 'ruby' },
    root_dir = vim.fs.dirname(
      vim.fs.find({ 'Gemfile', '.ruby-version', '.git' }, { upward = true })[1]
    ) or vim.fn.getcwd(),
    capabilities = get_capabilities(),
    init_options = {
      formatter = 'rubocop',
      linters = { 'rubocop' },
    },
    handlers = {
      -- RuboCop cops crash on half-typed buffers, and the default handler's hit-enter prompt blocks typing
      ['window/showMessage'] = function(err, params, ctx)
        if params.message:match('^Error running diagnostics') then
          vim.lsp.log.warn('ruby_lsp: ' .. params.message)
          return params
        end
        return vim.lsp.handlers['window/showMessage'](err, params, ctx)
      end,
    },
  })

  vim.lsp.enable('ruby_lsp')
end

return M

-- Ruby LSP configuration
local M = {}

function M.setup()
  local function get_ruby_lsp_cmd()
    local mason_registry = require('mason-registry')
    if mason_registry.is_installed('ruby-lsp') then
      local ruby_lsp = mason_registry.get_package('ruby-lsp')
      return { ruby_lsp:get_install_path() .. '/ruby-lsp' }
    else
      return { 'ruby-lsp' }
    end
  end

  local root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'Gemfile', '.ruby-version' }, { upward = true })[1] or vim.fn.getcwd())

  vim.lsp.config('ruby_lsp', {
    cmd = get_ruby_lsp_cmd(),
    filetypes = { 'ruby' },
    root_dir = root_dir,
    settings = {
      rubyLsp = {
        formatter = 'rubocop',
        enabledFeatures = {
          rubocop = true,
        },
      },
    },
  })

  -- Enable Ruby LSP
  vim.lsp.enable('ruby_lsp')
end

return M

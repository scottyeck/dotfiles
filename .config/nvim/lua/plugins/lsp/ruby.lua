-- Ruby LSP configuration
local M = {}

function M.setup()
  vim.lsp.config('ruby_lsp', {
    cmd = { 'ruby-lsp' },
    filetypes = { 'ruby' },
    root_markers = { '.ruby-version', 'Gemfile', '.git' },
    settings = {
      rubyLsp = {
        formatter = 'rubocop',
        enabledFeatures = {
          rubocop = true,
        },
      },
    },
    on_new_config = function(config, root_dir)
      -- Read .ruby-version from the project root to set RBENV_VERSION
      local ruby_version_file = root_dir .. '/.ruby-version'
      local f = io.open(ruby_version_file, 'r')
      if f then
        local version = f:read('*l')
        f:close()
        if version then
          version = version:gsub('%s+', '') -- trim whitespace
          config.cmd_env = config.cmd_env or {}
          config.cmd_env.RBENV_VERSION = version
        end
      end
    end,
  })

  -- Enable Ruby LSP
  vim.lsp.enable('ruby_lsp')
end

return M

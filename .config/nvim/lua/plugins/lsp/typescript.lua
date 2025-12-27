-- TypeScript LSP configuration
local M = {}

-- Get LSP capabilities (with completion support from nvim-cmp)
local function get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- Merge with cmp capabilities if available
  local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok then
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
  end
  return capabilities
end

function M.setup()
  local function get_typescript_lsp_cmd()
    local ok, mason_registry = pcall(require, 'mason-registry')
    if ok and mason_registry.is_installed('typescript-language-server') then
      local tsserver = mason_registry.get_package('typescript-language-server')
      if tsserver then
        local success, install_path = pcall(function() return tsserver:get_install_path() end)
        if success and install_path then
          return { install_path .. '/typescript-language-server', '--stdio' }
        end
      end
    end
    -- Fallback to global installation (we installed it via npm)
    return { 'typescript-language-server', '--stdio' }
  end

  local root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'package.json', 'tsconfig.json' }, { upward = true })[1] or vim.fn.getcwd())

  vim.lsp.config('typescript', {
    cmd = get_typescript_lsp_cmd(),
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    root_dir = root_dir,
    capabilities = get_capabilities(),
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        preferences = {
          providePrefixAndSuffixTextForRename = true,
          allowRenameOfImportPath = true,
        },
        -- Ensure TypeScript validation doesn't interfere with ESLint
        validate = true,
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        preferences = {
          providePrefixAndSuffixTextForRename = true,
          allowRenameOfImportPath = true,
        },
        -- Ensure JavaScript validation doesn't interfere with ESLint
        validate = true,
      },
    },
  })

  -- Enable TypeScript LSP
  vim.lsp.enable('typescript')
end

return M

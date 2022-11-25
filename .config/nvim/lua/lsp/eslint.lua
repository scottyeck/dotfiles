local M = {
  setup = function(on_attach, capabilities)
    local lspconfig = require("lspconfig")

    lspconfig["eslint"].setup({
      root_dir = lspconfig.util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.json"),
      on_attach = function(client, bufnr)
        -- @see https://github.com/neovim/nvim-lspconfig/pull/1299#issuecomment-942214556
        client.resolved_capabilities.document_formatting = true
        on_attach(client, bufnr)
      end,
      capabilities = capabilities,
      settings = {
        format = {
          enable = true,
        },
        -- TODO: Could make this dynamic based on presence of package-lock.json or yarn.lock
        packageManager = "yarn",
      },
      handlers = {
        -- this error shows up occasionally when formatting
        -- formatting actually works, so this will supress it
        ["window/showMessageRequest"] = function(_, result)
          if result.message:find("ENOENT") then
            return vim.NIL
          end

          return vim.lsp.handlers["window/showMessageRequest"](nil, result)
        end,
      },
    })
  end,
}

return M

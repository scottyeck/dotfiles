local utils = require('utils')

local M = {}
M.setup = function(on_attach, capabilities)
  require("typescript").setup({
    server = {
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        utils.buf_map(bufnr, "n", "gs", ":TypescriptRemoveUnused<CR>")
        utils.buf_map(bufnr, "n", "gs", ":TypescriptOrganizeImports<CR>")
        utils.buf_map(bufnr, "n", "go", ":TypescriptAddMissingImports<CR>")
        utils.buf_map(bufnr, "n", "gI", ":TypescriptFixAll<CR>")

        on_attach(client, bufnr)
      end,
      capabilities = capabilities
    }
  })
end

return M

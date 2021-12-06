local lspconfig = require("lspconfig")

local M = {}
M.setup = function(on_attach)
  lspconfig.solargraph.setup({})
end

return M

local utils = require('utils')

local lsp = vim.lsp

local border_opts = { border = "single", focusable = false, scope = "line" }
vim.diagnostic.config({ virtual_text = false, float = border_opts })

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

local on_attach = function(client, bufnr)
  -- commands
  utils.command("LspFormatting", vim.lsp.buf.formatting)
  utils.command("LspHover", vim.lsp.buf.hover)
  utils.command("LspDiagPrev", vim.diagnostic.goto_prev)
  utils.command("LspDiagNext", vim.diagnostic.goto_next)
  utils.command("LspDiagLine", vim.diagnostic.open_float)
  utils.command("LspDiagQuickfix", vim.diagnostic.setqflist)
  utils.command("LspSignatureHelp", vim.lsp.buf.signature_help)
  utils.command("LspTypeDef", vim.lsp.buf.type_definition)
  utils.command("LspRangeAct", vim.lsp.buf.range_code_action)

  -- bindings
  utils.buf_map(bufnr, "n", "gr", ":LspRename<CR>")
  utils.buf_map(bufnr, "n", "K", ":LspHover<CR>")
  utils.buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>")
  utils.buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>")
  utils.buf_map(bufnr, "n", "<Leader>a", ":LspDiagLine<CR>")
  utils.buf_map(bufnr, "n", "<Leader>a", ":LspDiagQuickfix<CR>")
  utils.buf_map(bufnr, "i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>")

  utils.buf_map(bufnr, "n", "gd", ":LspDef<CR>")
  utils.buf_map(bufnr, "n", "gR", ":LspRef<CR>")
  utils.buf_map(bufnr, "n", "ga", ":LspAct<CR>")
  utils.buf_map(bufnr, "v", "ga", "<Esc><cmd> LspRangeAct<CR>")

  -- TODO: Formatting is currently broken
  if client.supports_method("textDocument/formatting") then
    -- vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
        vim.cmd([[
          augroup LspFormatting
              autocmd! * <buffer>
              autocmd BufWritePre <buffer> lua formatting(vim.fn.expand("<abuf>"))
          augroup END
        ]])
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- TODO: Update capabilities with use of cmp_nvim_lsp

for _, server in
  ipairs({
    "eslint",
    "null-ls",
    "solargraph",
    "tsserver",
  })
do
  require("lsp." .. server).setup(on_attach, capabilities)
end


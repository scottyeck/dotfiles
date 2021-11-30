local u = require("utils")

local lsp = vim.lsp

-- TODO: This relies on Neovim 0.6 (head)
-- vim.diagnostic.config({ virtual_text = false, float = border_opts })

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

local on_attach = function(client, bufnr)
  -- commands
  u.lua_command("LspDef", "vim.lsp.buf.definition()")
  u.lua_command("LspFormatting", "vim.lsp.buf.formatting()")
  u.lua_command("LspCodeAction", "vim.lsp.buf.code_action()")
  u.lua_command("LspHover", "vim.lsp.buf.hover()")
  u.lua_command("LspRename", "vim.lsp.buf.rename()")
  u.lua_command("LspDiagPrev", "vim.diagnostic.goto_prev()")
  u.lua_command("LspDiagNext", "vim.diagnostic.goto_next()")
  u.lua_command("LspDiagLine", "vim.diagnostic.open_float(nil, global.lsp.border_opts)")
  u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")
  u.lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")

  -- bindings
  u.buf_map("n", "gd", ":LspDef<CR>", nil, bufnr)
  u.buf_map("n", "gr", ":LspRename<CR>", nil, bufnr)
  u.buf_map("n", "gy", ":LspTypeDef<CR>", nil, bufnr)
  u.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
  u.buf_map("n", "ga", ":LspCodeAction<CR>", nil, bufnr)
  u.buf_map("n", "[a", ":LspDiagPrev<CR>", nil, bufnr)
  u.buf_map("n", "]a", ":LspDiagNext<CR>", nil, bufnr)
  u.buf_map("n", "<Leader>a", ":LspDiagLine<CR>", nil, bufnr)
  u.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

  if client.resolved_capabilities.document_formatting then
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
  end
end

require("lsp.tsserver").setup(on_attach)
require("lsp.null-ls").setup(on_attach)


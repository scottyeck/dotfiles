local utils = require('utils')

local lsp = vim.lsp
local api = vim.api

local border_opts = { border = "single", focusable = false, scope = "line" }
vim.diagnostic.config({ virtual_text = false, float = border_opts })

-- TODO: What is this for?
local eslint_disabled_buffers = {}

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

-- track buffers that eslint can't format to use prettier instead
lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
  local client = lsp.get_client_by_id(ctx.client_id)
  if not (client and client.name == "eslint") then
    goto done
  end

  for _, diagnostic in ipairs(result.diagnostics) do
    if diagnostic.message:find("The file does not match your project config") then
      local bufnr = vim.uri_to_bufnr(result.uri)
      eslint_disabled_buffers[bufnr] = true
    end
  end

  ::done::
  return lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, config)
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(bufnr)
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  lsp.buf.format({
    bufnr = bufnr,
    filter = function(client)
      if client.name == "eslint" then
        return not eslint_disabled_buffers[bufnr]
      end

      if client.name == "null-ls" then
        return not utils.table.some(clients, function(_, other_client)
          return other_client.name == "eslint" and not eslint_disabled_buffers[bufnr]
        end)
      end
    end,
  })
end

local on_attach = function(client, bufnr)
  -- commands
  utils.command("LspFormatting", vim.lsp.buf.format)
  utils.command("LspHover", vim.lsp.buf.hover)
  utils.command("LspDiagPrev", vim.diagnostic.goto_prev)
  utils.command("LspDiagNext", vim.diagnostic.goto_next)
  utils.command("LspDiagLine", vim.diagnostic.open_float)
  utils.command("LspDiagQuickfix", vim.diagnostic.setqflist)
  utils.command("LspSignatureHelp", vim.lsp.buf.signature_help)
  utils.command("LspTypeDef", vim.lsp.buf.type_definition)
  utils.command("LspRangeAct", vim.lsp.buf.range_code_action)
  utils.command("LspRename", function()
    vim.lsp.buf.rename()
  end)

  -- bindings
  utils.buf_map(bufnr, "n", "gr", ":LspRename<CR>")
  utils.buf_map(bufnr, "n", "K", ":LspHover<CR>")
  utils.buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>")
  utils.buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>")
  utils.buf_map(bufnr, "n", "<Leader>a", ":LspDiagLine<CR>")
  utils.buf_map(bufnr, "n", "<Leader>a", ":LspDiagQuickfix<CR>")
  utils.buf_map(bufnr, "i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>")

  utils.buf_map(bufnr, "n", "gd", ":LspDef<CR>")
  utils.buf_map(bufnr, "n", "gy", ":LspTypeDef<CR>")
  utils.buf_map(bufnr, "n", "gR", ":LspRef<CR>")
  utils.buf_map(bufnr, "n", "ga", ":LspAct<CR>")
  utils.buf_map(bufnr, "v", "ga", "<Esc><cmd> LspRangeAct<CR>")

  if client.supports_method("textDocument/formatting") then
    utils.buf_command(bufnr, "LspFormatting", function()
      lsp_formatting(bufnr)
    end)

    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", { group = augroup, buffer = bufnr, command = "LspFormatting" })
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


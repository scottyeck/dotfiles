local utils = require('utils')

local lsp = vim.lsp
local api = vim.api

local border_opts = { border = "single", focusable = false, scope = "line" }
vim.diagnostic.config({ virtual_text = false, float = border_opts })

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, border_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, border_opts)

-- use lsp formatting if it's available (and if it's good)
-- otherwise, fall back to null-ls
local preferred_formatting_clients = {
  -- Formatting using eslint is not working consistently so we avoid use.
  -- "eslint",
  "null-ls"
}
local fallback_formatting_client = "null-ls"

-- prevent repeated lookups
local buffer_client_ids = {}

_G.formatting = function(bufnr)
  bufnr = tonumber(bufnr) or api.nvim_get_current_buf()

  local selected_client
  if buffer_client_ids[bufnr] then
    selected_client = lsp.get_client_by_id(buffer_client_ids[bufnr])
  else
    for _, client in pairs(lsp.buf_get_clients(bufnr)) do
      if vim.tbl_contains(preferred_formatting_clients, client.name) then
        selected_client = client
        break
      end

      if client.name == fallback_formatting_client then
        selected_client = client
      end
    end
  end

  if not selected_client then
    return
  end

  buffer_client_ids[bufnr] = selected_client.id

  local params = lsp.util.make_formatting_params()
  selected_client.request("textDocument/formatting", params, function(err, res)
    if err then
      local err_msg = type(err) == "string" and err or err.message
      vim.notify("global.lsp.formatting: " .. err_msg, vim.log.levels.WARN)
      return
    end

    if not api.nvim_buf_is_loaded(bufnr) or api.nvim_buf_get_option(bufnr, "modified") then
      return
    end

    if res then
      lsp.util.apply_text_edits(res, bufnr, selected_client.offset_encoding or "utf-16")
      api.nvim_buf_call(bufnr, function()
        vim.cmd("silent noautocmd update")
      end)
    end
  end, bufnr)
end


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


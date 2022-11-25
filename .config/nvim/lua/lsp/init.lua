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

local async_formatting = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    vim.lsp.buf_request(
        bufnr,
        "textDocument/formatting",
        vim.lsp.util.make_formatting_params({}),
        function(err, res, ctx)
            if err then
                local err_msg = type(err) == "string" and err or err.message
                -- you can modify the log message / level (or ignore it completely)
                vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
                return
            end

            -- don't apply results if buffer is unloaded or has been modified
            if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
                return
            end

            if res then
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("silent noautocmd update")
                end)
            end
        end
    )
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
  utils.buf_map(bufnr, "x", "ga", function()
     vim.lsp.buf.code_action() -- range
  end)
  utils.buf_map(bufnr, "v", "ga", "<Esc><cmd> LspRangeAct<CR>")

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    -- Temporarily preferring use of eslint-language-server for formatting
    -- rather than relying on null-ls / prettier for ease-of-use.
    vim.cmd(string.format([[
      augroup __eslint_autofix
        autocmd!
        autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll
      augroup END
    ]], tostring(bufnr)))
    -- vim.api.nvim_create_autocmd("BufWritePost", { group = augroup, buffer = bufnr, callback = function()
    --   async_formatting(bufnr)
    -- end})
 end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- TODO: Update capabilities with use of cmp_nvim_lsp

for _, server in
  ipairs({
    "eslint",
    -- "null-ls",
    "solargraph",
    "tsserver",
  })
do
  require("lsp." .. server).setup(on_attach, capabilities)
end


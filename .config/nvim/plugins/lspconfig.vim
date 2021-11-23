Plug 'neovim/nvim-lspconfig'
Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'

" TS dev setup via Jose Alvarez
" @see https://jose-elias-alvarez.medium.com/configuring-neovims-lsp-client-for-typescript-development-5789d58ea9c
" TODO: Consider usage of additional utils: https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils

function LspConfigSetup()
lua << EOF
local lspconfig = require'lspconfig'

local format_async = function(err, _, result, _, bufnr)
  if err ~= nil or result == nil then return end
  if not vim.api.nvim_buf_get_option(bufnr, "modified") then
    local view = vim.fn.winsaveview()
    vim.lsp.util.apply_text_edits(result, bufnr)
    vim.fn.winrestview(view)
    if bufnr == vim.api.nvim_get_current_buf() then
      vim.api.nvim_command("noautocmd :update")
    end
  end
end

vim.lsp.handlers["textDocument/formatting"] = format_async

-- _G.lsp_organize_imports = function()
--   local params = {
--     command = "_typescript.organizeImports",
--     arguments = {vim.api.nvim_buf_get_name(0)},
--     title = ""
--   }
--   vim.lsp.buf.execute_command(params)
-- end

local on_attach = function(client, bufnr)

  local ts_utils = require("nvim-lsp-ts-utils")

  ts_utils.setup {
    debug = false,
    disable_commands = false,
    enable_import_on_completion = false,

    -- import all
    import_all_timeout = 5000, -- ms
    import_all_priorities = {
        buffers = 4, -- loaded buffer names
        buffer_content = 3, -- loaded buffer content
        local_files = 2, -- git files or files with relative path markers
        same_file = 1, -- add to existing import statement
    },
    import_all_scan_buffers = 100,
    import_all_select_source = false,

    -- update imports on file move
    update_imports_on_move = false,
    require_confirmation_on_move = false,
    watch_dir = nil,
  }

  ts_utils.setup_client(client)

  vim.cmd("command! LspDef lua vim.lsp.buf.definition()")
  vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")
  vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
  vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
  vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
  vim.cmd("command! LspOrganize lua lsp_organize_imports()")
  vim.cmd("command! LspRefs lua vim.lsp.buf.references()")
  vim.cmd("command! LspTypeDef lua vim.lsp.buf.type_definition()")
  vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
  vim.cmd("command! LspDiagPrev lua vim.lsp.diagnostic.goto_prev()")
  vim.cmd("command! LspDiagNext lua vim.lsp.diagnostic.goto_next()")
  vim.cmd("command! LspDiagLine lua vim.lsp.diagnostic.show_line_diagnostics()")
  vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")

  -- Standard LSP
  local buf_map = vim.api.nvim_buf_set_keymap
  local opts = { silent = true }
  buf_map(bufnr, "n", "gd", ":LspDef<CR>", opts)
  buf_map(bufnr, "n", "gr", ":LspRename<CR>", opts)
  buf_map(bufnr, "n", "gR", ":LspRefs<CR>", opts)
  buf_map(bufnr, "n", "gy", ":LspTypeDef<CR>", opts)
  buf_map(bufnr, "n", "K", ":LspHover<CR>", opts)
  -- Disable native LspOrganize in favor of TSLspOrganize below
  -- buf_map(bufnr, "n", "gs", ":LspOrganize<CR>", opts)
  buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>", opts)
  buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>", opts)
  buf_map(bufnr, "n", "ga", ":LspCodeAction<CR>", opts)
  buf_map(bufnr, "n", "<Leader>a", ":LspDiagLine<CR>", opts)
  buf_map(bufnr, "i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", opts)
  -- LSP TS Utils
  buf_map(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
  buf_map(bufnr, "n", "qq", ":TSLspFixCurrent<CR>", opts)
  buf_map(bufnr, "n", "<Leader>R", ":TSLspRenameFile<CR>", opts)
  buf_map(bufnr, "n", "gi", ":TSLspImportAll<CR>", opts)

  if client.resolved_capabilities.document_formatting then
    vim.api.nvim_exec([[
     augroup LspAutocommands
         autocmd! * <buffer>
         autocmd BufWritePost <buffer> LspFormatting
     augroup END
     ]], true)
  end

end

lspconfig.tsserver.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end
}

lspconfig.solargraph.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end
}

local filetypes = {
  typescript = "eslint",
  typescriptreact = "eslint",
  javascript = "eslint",
  javascriptreact = "eslint",
  --json = 'eslint',
  ruby = "rubocop"
}

local linters = {
  eslint = {
    sourceName = "eslint",
    command = "eslint_d",
    rootPatterns = {".eslintrc.js", "package.json"},
    debounce = 100,
    args = {"--stdin", "--stdin-filename", "%filepath", "--format", "json"},
    parseJson = {
      errorsRoot = "[0].messages",
      line = "line",
      column = "column",
      endLine = "endLine",
      endColumn = "endColumn",
      message = "${message} [${ruleId}]",
      security = "severity"
    },
    securities = {[2] = "error", [1] = "warning"}
  },
  rubocop = {
    command = "bundle",
    sourceName = "rubocop",
    debounce = 100,
    args = { "exec", "rubocop", "--format", "json", "--force-exclusion", "--stdin", "%filepath" },
    parseJson = {
      errorsRoot = "files[0].offenses",
      line = "location.start_line",
      endLine = "location.last_line",
      column = "location.start_column",
      endColumn = "location.end_column",
      message = "[${cop_name}] ${message}",
      security = "severity"
    },
    securities = {
      fatal = "error",
      error = "error",
      warning = "warning",
      convention = "info",
      refactor = "info",
      info = "info"
    }
  }
}

local formatters = {
  prettier = {command = "prettier", args = {"--stdin-filepath", "%filepath"}}
}

local formatFiletypes = {
  json = "prettier",
  javascript = "prettier",
  javascriptreact = "prettier",
  ["javascript.jsx"] = "prettier",
  typescript = "prettier",
  typescriptreact = "prettier",
  ["typescript.tsx"] = "prettier",
  json = "prettier"
}

lspconfig.diagnosticls.setup {
  on_attach = on_attach,
  filetypes = vim.tbl_keys(filetypes),
  init_options = {
    filetypes = filetypes,
    linters = linters,
    formatters = formatters,
    formatFiletypes = formatFiletypes
  }
}

EOF
endfunction

augroup LspConfigSetup
  autocmd!
  autocmd User PlugLoaded call LspConfigSetup()
augroup END


local utils = require('utils')
local lspconfig = require("lspconfig")

local ts_utils_settings = {
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

    -- filter diagnostics
    filter_out_diagnostics_by_severity = {},
    filter_out_diagnostics_by_code = {},

    -- inlay hints
    auto_inlay_hints = true,
    inlay_hints_highlight = "Comment",

    import_all_scan_buffers = 100,
    import_all_select_source = false,

    -- update imports on file move
    update_imports_on_move = false,
    require_confirmation_on_move = false,
    watch_dir = nil,
}

local M = {}
M.setup = function(on_attach)
  local ts_utils = require('nvim-lsp-ts-utils')
  lspconfig.tsserver.setup({
    init_options = ts_utils.init_options,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false

      on_attach(client, bufnr)

      ts_utils.setup(ts_utils_settings)
      ts_utils.setup_client(client)

      utils.buf_map("n", "gs", ":TSLspOrganize<CR>", nil, bufnr)
      utils.buf_map("n", "gI", ":TSLspRenameFile<CR>", nil, bufnr)
      utils.buf_map("n", "go", ":TSLspImportAll<CR>", nil, bufnr)

      -- u.buf_map("i", ".", ".<C-x><C-o>", nil, bufnr)
    end,
    flags = {
      debounce_text_changes = 150,
    },
  })
end

return M

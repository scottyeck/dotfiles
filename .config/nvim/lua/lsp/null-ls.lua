local null_ls = require("null-ls")
local builtins = null_ls.builtins

local diagnostics_code_template = "#{m} [#{c}]"

local with_root_file = function(...)
  local files = { ... }
  return function(utils)
      return utils.root_has_file(files)
  end
end

-- TODO: Audit this.
local sources = {
    -- formatting
    builtins.formatting.prettier,
    -- builtins.formatting.prettier.with({
    --   condition = with_root_file(".prettierrc") or with_root_file(".prettierrc.json"),
    -- }),
    builtins.formatting.shfmt,
    builtins.formatting.trim_whitespace.with({ filetypes = { "tmux", "teal" } }),
    builtins.diagnostics.shellcheck.with({
        diagnostics_format = diagnostics_code_template,
    }),
    -- code actions
    builtins.code_actions.gitsigns,
    builtins.code_actions.gitrebase,
    -- hover
    builtins.hover.dictionary,
}

local M = {}
M.setup = function(on_attach)
  null_ls.setup({
    sources = sources,
    on_attach = on_attach
  })
end

return M

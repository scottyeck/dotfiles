local null_ls = require("null-ls")
local builtins = null_ls.builtins

local eslint_opts = {
    condition = function(utils)
        return utils.root_has_file(".eslintrc.js")
    end,
    diagnostics_format = "#{m} [#{c}]",
}

local sources = {
    builtins.formatting.prettier.with({
        disabled_filetypes = { "typescript", "typescriptreact" },
    }),
    builtins.diagnostics.eslint_d.with(eslint_opts),
    builtins.formatting.eslint_d.with(eslint_opts),
    builtins.code_actions.eslint_d.with(eslint_opts),
    -- builtins.formatting.stylua.with({
    --     condition = function(utils)
    --         return utils.root_has_file("stylua.toml")
    --     end,
    -- }),
    builtins.formatting.trim_whitespace.with({ filetypes = { "tmux", "teal", "zsh" } }),
    -- builtins.formatting.shfmt,
    -- builtins.diagnostics.write_good,
    -- builtins.diagnostics.markdownlint,
    -- builtins.diagnostics.teal,
    -- builtins.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
    -- builtins.code_actions.gitsigns,
    -- builtins.code_actions.gitrebase,
    builtins.hover.dictionary,
}

local M = {}
M.setup = function(on_attach)
    null_ls.config({
        -- debug = true,
        sources = sources,
    })
    require("lspconfig")["null-ls"].setup({ on_attach = on_attach })
end

return M

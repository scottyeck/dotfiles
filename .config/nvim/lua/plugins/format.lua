-- Formatting configuration
-- Prettier, conform.nvim, and format-on-save autocmds
return {
  -- Conform: Formatter for non-JS/TS files
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    -- init runs BEFORE the plugin loads (sets up autocmd early)
    init = function()
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.json", "*.jsonc", "*.yaml", "*.yml", "*.md", "*.html", "*.css", "*.scss" },
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
    config = function()
      -- Helper to find local executable in node_modules
      local function find_local_executable(cmd, filename)
        local root_file = vim.fs.find({ "package.json", "node_modules" }, { upward = true, path = filename })[1]
        if root_file then
          local root = vim.fs.dirname(root_file)
          local local_cmd = root .. "/node_modules/.bin/" .. cmd
          if vim.fn.executable(local_cmd) == 1 then
            return local_cmd
          end
        end
        return nil
      end

      require("conform").setup({
        formatters_by_ft = {
          -- Remove JS/TS from conform - using prettier.nvim + null-ls instead
          json = { "prettier_local" },
          jsonc = { "prettier_local" },
          yaml = { "prettier_local" },
          markdown = { "prettier_local" },
          html = { "prettier_local" },
          css = { "prettier_local" },
          scss = { "prettier_local" },
        },
        formatters = {
          prettier_local = {
            command = function(ctx)
              return find_local_executable("prettier", ctx.filename) or "prettier"
            end,
            args = { "--stdin-filepath", "$FILENAME" },
            stdin = true,
          },
        },
      })
    end,
  },

  -- Prettier.nvim: Prettier formatter for JS/TS
  {
    "MunifTanjim/prettier.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "css", "html", "json", "yaml", "markdown", "graphql" },
    config = function()
      local prettier = require("prettier")

      -- prettier.nvim only accepts "prettier" or "prettierd" as bin values
      -- It handles finding local node_modules binaries internally
      local function get_prettier_bin()
        if vim.fn.executable("prettierd") == 1 then
          return "prettierd"
        end
        return "prettier"
      end

      local bin = get_prettier_bin()

      prettier.setup({
        bin = bin,
        filetypes = {
          "css",
          "graphql",
          "html",
          "javascript",
          "javascriptreact",
          "json",
          "less",
          "markdown",
          "scss",
          "typescript",
          "typescriptreact",
          "yaml",
        },
        -- Find local prettier in node_modules
        find_config_file = function()
          return vim.fs.find({ ".prettierrc", ".prettierrc.js", ".prettierrc.json", "prettier.config.js", "package.json" }, { upward = true })[1]
        end,
      })
      -- Note: Format-on-save autocmd is in init.lua (must run after lazy.setup)
    end,
  },
}

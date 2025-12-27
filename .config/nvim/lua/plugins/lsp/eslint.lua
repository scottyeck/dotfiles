-- ESLint configuration via null-ls (none-ls.nvim)
return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  config = function()
    local null_ls = require("null-ls")
    local helpers = require("null-ls.helpers")

    -- Helper to find eslint executable per-file (prefers local eslint for plugin support, then eslint_d)
    local function find_eslint(filename)
      -- Prefer local eslint first (has access to project's node_modules plugins)
      -- Find from the file's location, not current working directory
      local root_file = vim.fs.find({ "package.json", "node_modules" }, { upward = true, path = filename })[1]
      if root_file then
        local root = vim.fs.dirname(root_file)

        -- Try local eslint first (best for plugin support)
        local local_eslint = root .. "/node_modules/.bin/eslint"
        if vim.fn.executable(local_eslint) == 1 then
          return local_eslint
        end

        -- Try local eslint_d (might work with plugins if run from project root)
        local local_eslint_d = root .. "/node_modules/.bin/eslint_d"
        if vim.fn.executable(local_eslint_d) == 1 then
          return local_eslint_d
        end
      end

      -- Fallback to global eslint_d
      if vim.fn.executable("eslint_d") == 1 then
        return "eslint_d"
      end

      -- Final fallback to global eslint
      return "eslint"
    end

    -- Check if eslint config exists
    local function has_eslint_config()
      local eslint_config = vim.fs.find({
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.json",
        ".eslintrc.cjs",
        ".eslintrc.mjs",
        "eslint.config.js",
        "eslint.config.mjs"
      }, { upward = true })[1]

      return eslint_config ~= nil
    end

    local sources = {}

    if has_eslint_config() then
      -- ESLint diagnostics using custom source
      table.insert(sources, helpers.make_builtin({
        name = "eslint_diagnostics",
        meta = {
          url = "https://eslint.org/",
          description = "ESLint diagnostics",
        },
        method = null_ls.methods.DIAGNOSTICS,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        generator_opts = {
          command = function(params)
            -- Find project root and return absolute path to eslint
            local filename = params.bufname or params.filename or vim.api.nvim_buf_get_name(params.bufnr or 0)
            return find_eslint(filename)
          end,
          runtime_condition = function(params)
            -- Always run if eslint config exists (find_eslint will handle fallbacks)
            local filename = params.bufname or params.filename or vim.api.nvim_buf_get_name(params.bufnr or 0)

            local root_file = vim.fs.find({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.cjs",
              ".eslintrc.mjs",
              "eslint.config.js",
              "eslint.config.mjs"
            }, { upward = true, path = filename })[1]

            if root_file then
              -- Check if any eslint executable is available
              local eslint_cmd = find_eslint(filename)
              if eslint_cmd and vim.fn.executable(eslint_cmd) == 1 then
                return true
              end
            end
            return false
          end,
          args = { "--format", "json", "--stdin", "--stdin-filename", "$FILENAME" },
          to_stdin = true,
          format = "raw", -- Use raw to handle JSON parsing ourselves
          cwd = function(params)
            -- Find project root (where eslint config is) - this is critical for plugin resolution
            local filename = params.bufname or params.filename or vim.api.nvim_buf_get_name(params.bufnr or 0)

            local root_file = vim.fs.find({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.cjs",
              ".eslintrc.mjs",
              "eslint.config.js",
              "eslint.config.mjs",
              "package.json"
            }, { upward = true, path = filename })[1]

            local cwd = root_file and vim.fs.dirname(root_file) or nil
            return cwd
          end,
          check_exit_code = function(code)
            return code <= 1 -- 0 = no issues, 1 = issues found
          end,
          on_output = function(params, done)
            local diagnostics = {}
            local output = params.output

            if not output then
              if done then
                done(diagnostics)
              end
              return
            end

            -- Parse JSON if it's a string
            if type(output) == "string" then
              local ok, parsed = pcall(vim.json.decode, output)
              if ok and parsed then
                output = parsed
              else
                if done then
                  done(diagnostics)
                end
                return
              end
            end

            -- ESLint JSON output is an array of file results
            if type(output) == "table" then
              for i, result in ipairs(output) do
                if result and type(result) == "table" then
                  if result.messages and type(result.messages) == "table" then
                    for j, message in ipairs(result.messages) do
                      if message.severity and message.severity > 0 then
                        -- Convert to 0-indexed (Neovim uses 0-indexed)
                        local row = (message.line or 1) - 1
                        local col = (message.column or 1) - 1
                        local end_row = (message.endLine or message.line or 1) - 1
                        local end_col = (message.endColumn or message.column or 1) - 1

                        -- severity: 1 = warning, 2 = error
                        -- Neovim: 1 = error, 2 = warning
                        local severity = message.severity == 2 and 1 or 2

                        table.insert(diagnostics, {
                          row = row,
                          col = col,
                          end_row = end_row,
                          end_col = end_col,
                          code = message.ruleId,
                          message = message.message or "",
                          severity = severity,
                          source = "eslint",
                        })
                      end
                    end
                  end
                end
              end
            end

            if done then
              done(diagnostics)
            end
          end,
        },
        factory = helpers.generator_factory,
      }))

      -- ESLint formatting (autofix on save)
      table.insert(sources, helpers.make_builtin({
        name = "eslint_fix",
        meta = {
          url = "https://eslint.org/",
          description = "ESLint autofix",
        },
        method = null_ls.methods.FORMATTING,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        generator_opts = {
          -- Use relative path - cwd will be set to project root where node_modules exists
          command = "node_modules/.bin/eslint",
          runtime_condition = function(params)
            -- Only run if local eslint exists in project
            local filename = params.bufname or params.filename or vim.api.nvim_buf_get_name(params.bufnr or 0)
            local root_file = vim.fs.find({ "package.json", "node_modules" }, { upward = true, path = filename })[1]
            if root_file then
              local root = vim.fs.dirname(root_file)
              local local_eslint = root .. "/node_modules/.bin/eslint"
              return vim.fn.executable(local_eslint) == 1
            end
            return false
          end,
          args = { "--fix", "--stdin", "--stdin-filename", "$FILENAME" },
          to_stdin = true,
          format = "raw",
          cwd = function(params)
            -- Find project root (where eslint config is) - this is critical for plugin resolution
            local filename = params.bufname or params.filename or vim.api.nvim_buf_get_name(params.bufnr or 0)
            local root_file = vim.fs.find({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.cjs",
              ".eslintrc.mjs",
              "eslint.config.js",
              "eslint.config.mjs",
              "package.json"
            }, { upward = true, path = filename })[1]
            return root_file and vim.fs.dirname(root_file) or nil
          end,
        },
        factory = helpers.formatter_factory,
      }))
    end

    null_ls.setup({
      sources = sources,
    })
  end,
}

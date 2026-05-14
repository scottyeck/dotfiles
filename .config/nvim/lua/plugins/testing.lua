-- Neotest: Test framework
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "antoinemadec/FixCursorHold.nvim",
    "olimorris/neotest-rspec", -- RSpec adapter
  },
  config = function()
    local function load_env_file(start_path)
      local found = vim.fs.find(".env.test.local", {
        upward = true,
        path = start_path,
        type = "file",
      })[1]
      if not found then return {} end

      local env = {}
      for line in io.lines(found) do
        if not line:match("^%s*#") and not line:match("^%s*$") then
          local k, v = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
          if k then
            v = v:gsub('^"(.*)"$', "%1"):gsub("^\'(.*)\'$", "%1")
            env[k] = v
          end
        end
      end
      return env
    end

    local function rspec_with_env()
      local start = vim.fn.expand("%:p:h")
      if start == "" then start = vim.fn.getcwd() end
      local env = load_env_file(start)
      local prefix = {}
      for k, v in pairs(env) do
        table.insert(prefix, string.format("%s=%s", k, v))
      end
      if #prefix == 0 then
        return { "bundle", "exec", "rspec" }
      end
      table.insert(prefix, 1, "env")
      vim.list_extend(prefix, { "bundle", "exec", "rspec" })
      return prefix
    end

    require("neotest").setup({
      adapters = {
        require("neotest-rspec")({
          rspec_cmd = rspec_with_env,
        }),
      },
      output_panel = {
        open = 'vsplit | vertical resize 80'
      },
    })

    vim.keymap.set('n', '<leader>tn', require('neotest').run.run, { desc = '[T]est [N]earest' })
    vim.keymap.set('n', '<leader>tf', function()
      require('neotest').run.run(vim.fn.expand('%'))
    end, { desc = '[T]est [F]ile' })
    vim.keymap.set('n', '<leader>ts', require('neotest').summary.toggle, { desc = '[T]est [S]ummary' })
    vim.keymap.set('n', '<leader>to', require('neotest').output.open, { desc = '[T]est [O]utput' })
    vim.keymap.set('n', '<leader>tp', require('neotest').output_panel.open, { desc = '[T]est Output [P]anel' })
    vim.keymap.set('n', '<leader>tS', function()
      require("neotest").run.run(vim.fn.getcwd())
    end, { desc = '[T]est [S]uite' })
  end,
}

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
    require("neotest").setup({
      adapters = {
        require("neotest-rspec")({
          rspec_cmd = function()
            return { "bundle", "exec", "rspec" }
          end,
        }),
        output_panel = {
          open = 'vsplit | vertical resize 80'
        },
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

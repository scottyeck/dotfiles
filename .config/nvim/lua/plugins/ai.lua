-- AI coding assistants
return {
  -- GitHub Copilot: Inline AI autocomplete
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = false,        -- Handled by Tab in completion.lua
            accept_word = "<M-w>", -- Alt+w to accept word
            accept_line = "<M-j>", -- Alt+j to accept line
            next = "<M-]>",        -- Alt+] for next suggestion
            prev = "<M-[>",        -- Alt+[ for previous suggestion
            dismiss = "<C-]>",     -- Ctrl+] to dismiss
          },
        },
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            open = "<M-CR>", -- Alt+Enter to open panel
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = true,
          gitrebase = false,
          ["."] = false,
        },
      })
    end,
  },

  -- Avante: AI chat assistant
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("avante").setup({
        -- Provider configuration
        -- You'll need to set your API key via environment variable or in the config
        -- For OpenAI: OPENAI_API_KEY
        -- For Anthropic: ANTHROPIC_API_KEY
        -- For other providers, see: https://github.com/yetone/avante.nvim#provider-configuration
        provider = "openai", -- or "anthropic", "google", etc.
        model = "gpt-4o", -- or "claude-3-5-sonnet-20241022", etc.

        -- UI settings
        ui = {
          border = "rounded",
          width = 0.8,
          height = 0.8,
        },

        -- Selector settings
        selector = {
          exclude_auto_select = { "NvimTree", "TelescopePrompt" },
        },
      })

      -- Keymaps
      local api = require("avante.api")
      vim.keymap.set("n", "<leader>aa", function() api.ask() end, { desc = "Avante Ask" })
      vim.keymap.set("n", "<leader>an", function() api.ask({ new_chat = true }) end, { desc = "Avante New Chat" })
      vim.keymap.set("v", "<leader>ae", function() api.edit() end, { desc = "Avante Edit Selection" })
      vim.keymap.set("n", "<leader>at", function() require("avante").toggle() end, { desc = "Avante Toggle" })
      vim.keymap.set("n", "<leader>af", function() api.focus() end, { desc = "Avante Focus" })
    end,
  },
}

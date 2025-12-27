-- Treesitter configuration
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "ruby", "lua", "vim", "vimdoc", "typescript", "javascript", "tsx" },
      auto_install = true,
      highlight = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- Ruby blocks
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            -- Functions/methods
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            -- Classes
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]b"] = "@block.outer",
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_next_end = {
            ["]B"] = "@block.outer",
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[b"] = "@block.outer",
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
          goto_previous_end = {
            ["[B"] = "@block.outer",
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
      },
    })
  end,
}

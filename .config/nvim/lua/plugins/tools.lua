-- Miscellaneous tools and utilities
return {
  -- File explorer (replaces vim-vinegar/netrw)
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup({
        default_file_explorer = true,
        columns = { 'icon' },
        keymaps = {
          ['g?'] = 'actions.show_help',
          ['<CR>'] = 'actions.select',
          ['<C-v>'] = 'actions.select_vsplit',
          ['<C-x>'] = 'actions.select_split',
          ['<C-t>'] = 'actions.select_tab',
          ['gp'] = 'actions.preview',
          ['q'] = 'actions.close',
          ['R'] = 'actions.refresh',
          ['-'] = 'actions.parent',
          ['_'] = 'actions.open_cwd',
          ['`'] = 'actions.cd',
          ['~'] = 'actions.tcd',
          ['gs'] = 'actions.change_sort',
          ['gx'] = 'actions.open_external',
          ['g.'] = 'actions.toggle_hidden',
          ['g\\'] = 'actions.toggle_trash',
          -- Pass through to global keymaps (vim-tmux-navigator, telescope)
          ['<C-h>'] = false,
          ['<C-j>'] = false,
          ['<C-k>'] = false,
          ['<C-l>'] = false,
          ['<C-p>'] = false,
        },
        use_default_keymaps = false,
        view_options = {
          show_hidden = true,
        },
        -- LSP file rename integration
        lsp_file_methods = {
          timeout_ms = 1000,
          autosave_changes = true,
        },
      })
      -- Use `-` to open parent directory (like vim-vinegar)
      vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })
    end,
  },

  -- Editing enhancements
  'christoomey/vim-tmux-navigator',
  'AndrewRadev/tagalong.vim',

  -- CSV syntax highlighting and tools
  'mechatroner/rainbow_csv',

  -- Git signs in the gutter
  'airblade/vim-gitgutter',

  -- Find and replace
  {
    'nvim-pack/nvim-spectre',
    config = function()
      vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
        desc = "Toggle Spectre"
      })
      vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
        desc = "Search current word"
      })
      vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
        desc = "Search current word"
      })
      vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
        desc = "Search on current file"
      })
    end
  },

  -- Theme
  {
    'oxfist/night-owl.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      local tmux_inactive_bg = '#303030' -- tmux window-style bg=colour236

      require('night-owl').setup()
      vim.cmd.colorscheme('night-owl')

      -- Dim background when Neovim loses focus to match tmux inactive pane
      vim.api.nvim_create_autocmd('FocusLost', {
        pattern = '*',
        callback = function()
          vim.api.nvim_set_hl(0, 'Normal', { bg = tmux_inactive_bg })
        end,
      })
      vim.api.nvim_create_autocmd('FocusGained', {
        pattern = '*',
        callback = function()
          vim.api.nvim_set_hl(0, 'Normal', { bg = '#011627' })
        end,
      })
    end,
  },

  -- VSCode tasks
  {
    "EthanJWright/vs-tasks.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require('vstask').setup({
        cache_json_conf = true,
        cache_strategy = "last",
        config_dir = ".vscode",
        support_code_workspace = true,
      })
      require('telescope').load_extension('vstask')

      -- Keymaps for vstask
      vim.keymap.set('n', '<leader>tt', function()
        require('telescope').extensions.vstask.tasks()
      end, { desc = '[T]asks' })
      vim.keymap.set('n', '<leader>tj', function()
        require('telescope').extensions.vstask.jobs()
      end, { desc = '[T]ask [J]obs' })
      vim.keymap.set('n', '<leader>th', function()
        require('telescope').extensions.vstask.history()
      end, { desc = '[T]ask [H]istory' })
      vim.keymap.set('n', '<leader>tr', function()
        require('telescope').extensions.vstask.run()
      end, { desc = '[T]ask [R]un command' })
    end,
  },

  -- Inline diagnostics
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup()
      -- Configure diagnostics to show in signcolumn and via tiny-inline-diagnostic
      vim.diagnostic.config({
        virtual_text = false, -- Disable Neovim's default virtual text (tiny-inline-diagnostic handles this)
        signs = true,         -- Show signs in signcolumn
        underline = true,     -- Underline errors
        update_in_insert = false, -- Don't update diagnostics while typing
        severity_sort = true, -- Sort by severity
        -- Show diagnostics from all sources (TypeScript LSP, ESLint, etc.)
        sources = nil,        -- nil means show all sources
      })
    end,
  },

  -- Zen mode for distraction-free editing
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup()
      vim.keymap.set('n', '<leader>z', '<cmd>ZenMode<cr>', { desc = '[Z]en mode' })
    end,
  },
}

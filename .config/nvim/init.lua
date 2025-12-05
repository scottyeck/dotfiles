-- Personal nvim config
-- @scottyeck - <scott.eckenthal@gmail.com>

-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.opt.hlsearch = false

-- Hybrid line nums (relative with absolute at anchor)
vim.wo.relativenumber = true
vim.wo.number = true

-- Enable mouse mode
vim.opt.mouse = 'a'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
-- vim.o.undofile = true
-- vim.wo.noswapfile = true

vim.opt.splitright = true
vim.opt.incsearch = true

-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeout = true
vim.opt.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

vim.opt.title = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Close all other open panes
vim.keymap.set('n', '<leader>o', ":only<CR>")

-- Center buffer on / search result
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- Maintain cursor position on linewise Join
vim.keymap.set('n', 'J', 'mzJ`z')

-- Move visual selections
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '<leader>qj', '<cmd>cnext<CR>')
vim.keymap.set('n', '<leader>qk', '<cmd>cprev<CR>')

-- ========================================================================== --
-- ==                               COMMANDS                               == --
-- ========================================================================== --

vim.api.nvim_create_user_command('ReloadConfig', 'source $MYVIMRC', {})

local group = vim.api.nvim_create_augroup('user_cmds', { clear = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
--   pattern = "*.tsx",
--   command = "set filetype=typescriptreact"
-- })

require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Tpope altar
  'tpope/vim-abolish',
  'tpope/vim-eunuch',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth',
  'tpope/vim-surround',
  'tpope/vim-vinegar',

  'tpope/vim-rails',

  -- Editing enhancements
  'nvim-pack/nvim-spectre',
  'christoomey/vim-tmux-navigator',
  'AndrewRadev/tagalong.vim',

  { -- Theme
    'haishanh/night-owl.vim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'night-owl'
    end,
  },

  { -- Telescope: Fuzzy finder
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      })

      -- Enable telescope fzf native, if installed
      pcall(telescope.load_extension, 'fzf')

      -- Keymaps
      vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/', function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
    end,
  },

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

  { -- Avante: AI coding assistant
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
  }
})
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
  {
    'tpope/vim-fugitive',
    config = function()
      vim.api.nvim_create_user_command('Glo', 'Git log --oneline', {})
      vim.api.nvim_create_user_command('Gwip',
        '!git add -A && git rm $(git ls-files --deleted) 2> /dev/null && git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"',
        {})
      
      vim.keymap.set('n', '<leader>ci', ':diffget //2<CR>', { desc = '[C]onflict take [I]ncoming' })
      vim.keymap.set('n', '<leader>cc', ':diffget //3<CR>', { desc = '[C]onflict take [C]urrent' })
      vim.keymap.set('n', '<leader>cb', ':diffget //2 | diffget //3<CR>', { desc = '[C]onflict take [B]oth' })
    end
  },
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth',
  'tpope/vim-surround',
  'tpope/vim-vinegar',

  'tpope/vim-rails',
  'tpope/vim-dispatch',

  'AndrewRadev/splitjoin.vim',
  'jgdavey/vim-blockle',

  -- Editing enhancements
  'christoomey/vim-tmux-navigator',
  'AndrewRadev/tagalong.vim',

  {
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
  },

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

      -- Recent branches picker
      vim.keymap.set('n', '<leader>gb', function()
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        local branches = {}
        local handle = io.popen("git branch --sort=-committerdate --format='%(refname:short)' 2>/dev/null | head -20")
        if handle then
          for line in handle:lines() do
            table.insert(branches, line)
          end
          handle:close()
        end

        if #branches == 0 then
          vim.notify('No branches found', vim.log.levels.WARN)
          return
        end

        pickers.new({}, {
          prompt_title = 'Recent Branches',
          finder = finders.new_table({
            results = branches,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                vim.cmd('Git checkout ' .. selection[1])
              end
            end)
            return true
          end,
        }):find()
      end, { desc = '[G]it [B]ranches [R]ecent' })
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
  },

  { -- Neotest: Test framework
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
  },

  { -- Mason: LSP server installer
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
      -- Auto-install LSP servers
      local mason_registry = require('mason-registry')
      mason_registry.refresh(function()
        if not mason_registry.is_installed('ruby-lsp') then
          local ruby_lsp = mason_registry.get_package('ruby-lsp')
          ruby_lsp:install()
        end
        if not mason_registry.is_installed('typescript-language-server') then
          local tsserver = mason_registry.get_package('typescript-language-server')
          tsserver:install()
        end
        if not mason_registry.is_installed('eslint-lsp') then
          local eslint_lsp = mason_registry.get_package('eslint-lsp')
          eslint_lsp:install()
        end
      end)
    end,
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
        require("tiny-inline-diagnostic").setup()
        vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
    end,
  },

  { -- Conform: Formatter (Prettier/ESLint) - Only for non-JS/TS files
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
            condition = function(ctx)
              return ctx.filename ~= nil and ctx.filename ~= ''
            end,
            command = function(ctx)
              return find_local_executable("prettier", ctx.filename) or "prettier"
            end,
            args = { "--stdin-filepath", "$FILENAME" },
            stdin = true,
            cwd = function(ctx)
              local root_file = vim.fs.find({ "package.json", ".prettierrc", ".prettierrc.js", ".prettierrc.json" }, { upward = true, path = ctx.filename })[1]
              return root_file and vim.fs.dirname(root_file) or nil
            end,
          },
        },
        format_on_save = {
          timeout_ms = 5000,
          lsp_fallback = true,
        },
      })

      -- Format on save for non-JS/TS files only
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.json", "*.jsonc", "*.yaml", "*.yml", "*.md", "*.html", "*.css", "*.scss" },
        callback = function(args)
          require("conform").format({ bufnr = args.buf })
        end,
      })
    end,
  },

  { -- Prettier.nvim: Prettier formatter
    "MunifTanjim/prettier.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    event = { "BufWritePre" },
    config = function()
      local prettier = require("prettier")

      prettier.setup({
        bin = 'prettier', -- or `'prettierd'` (v0.23.3+)
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

      -- Format on save for JS/TS files
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
        callback = function()
          prettier.format()
        end,
      })
    end,
  },

  { -- null-ls (none-ls.nvim): ESLint autofix
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      local helpers = require("null-ls.helpers")

      -- Helper to find eslint executable (prefers eslint_d, then local, then global)
      local function find_eslint()
        -- Try eslint_d first
        if vim.fn.executable("eslint_d") == 1 then
          return "eslint_d"
        end
        
        -- Try local eslint_d
        local root_file = vim.fs.find({ "package.json", "node_modules" }, { upward = true })[1]
        if root_file then
          local root = vim.fs.dirname(root_file)
          local local_eslint_d = root .. "/node_modules/.bin/eslint_d"
          if vim.fn.executable(local_eslint_d) == 1 then
            return local_eslint_d
          end
          local local_eslint = root .. "/node_modules/.bin/eslint"
          if vim.fn.executable(local_eslint) == 1 then
            return local_eslint
          end
        end
        
        -- Fallback to global eslint
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
        local eslint_cmd = find_eslint()
        
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
            command = eslint_cmd,
            args = { "--fix", "--stdin", "--stdin-filename", "$FILENAME" },
            to_stdin = true,
            format = "raw",
          },
          factory = helpers.formatter_factory,
        }))
      end

      null_ls.setup({
        sources = sources,
      })

      -- Format on save with ESLint autofix
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
        callback = function()
          vim.lsp.buf.format({
            filter = function(client)
              return client.name == "null-ls"
            end,
            async = false,
          })
        end,
      })
    end,
  }
})

-- ========================================================================== --
-- ==                           RUBY LSP CONFIG                            == --
-- ========================================================================== --

-- Set up LSP attach handler for keybindings
local lsp_attach_group = vim.api.nvim_create_augroup('lsp-attach', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_attach_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    local bufnr = event.buf
    
    -- For ESLint, only attach to files with valid paths
    if client.name == 'eslint' then
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if not filename or filename == '' or filename:match('^%w+://') then
        -- Skip files without valid paths (unsaved buffers, special buffers)
        return
      end
      
      -- Suppress ESLint path errors
      vim.lsp.handlers['textDocument/diagnostic'] = function(err, result, ctx, config)
        if err and err.message and err.message:match('path.*undefined') then
          -- Silently ignore path errors from ESLint
          return
        end
        -- Use default handler for other errors
        vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
      end
    end

    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    -- Keybindings
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
    map('<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, '[F]ormat document')

    -- Format on save for Ruby files
    if client.name == 'ruby_lsp' and client.supports_method(vim.lsp.protocol.Methods.textDocument_formatting) then
      local format_group = vim.api.nvim_create_augroup('ruby-format-on-save', { clear = true })
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = format_group,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

-- Configure Ruby LSP using built-in API
local function setup_ruby_lsp()
  local function get_ruby_lsp_cmd()
    local mason_registry = require('mason-registry')
    if mason_registry.is_installed('ruby-lsp') then
      local ruby_lsp = mason_registry.get_package('ruby-lsp')
      return { ruby_lsp:get_install_path() .. '/ruby-lsp' }
    else
      return { 'ruby-lsp' }
    end
  end

  local root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'Gemfile', '.ruby-version' }, { upward = true })[1] or vim.fn.getcwd())

  vim.lsp.config('ruby_lsp', {
    cmd = get_ruby_lsp_cmd(),
    filetypes = { 'ruby' },
    root_dir = root_dir,
    settings = {
      rubyLsp = {
        formatter = 'rubocop',
        enabledFeatures = {
          rubocop = true,
        },
      },
    },
  })

  -- Enable Ruby LSP
  vim.lsp.enable('ruby_lsp')
end

-- Set up Ruby LSP after Mason is ready
vim.api.nvim_create_autocmd('User', {
  pattern = 'MasonUpdateComplete',
  callback = setup_ruby_lsp,
  once = true,
})

-- Also try to set up immediately (in case Mason is already ready)
vim.defer_fn(function()
  if pcall(require, 'mason-registry') then
    setup_ruby_lsp()
  end
end, 1000)

-- ========================================================================== --
-- ==                        TYPESCRIPT LSP CONFIG                         == --
-- ========================================================================== --

local function setup_typescript_lsp()
  local function get_typescript_lsp_cmd()
    local ok, mason_registry = pcall(require, 'mason-registry')
    if ok and mason_registry.is_installed('typescript-language-server') then
      local tsserver = mason_registry.get_package('typescript-language-server')
      if tsserver then
        local success, install_path = pcall(function() return tsserver:get_install_path() end)
        if success and install_path then
          return { install_path .. '/typescript-language-server', '--stdio' }
        end
      end
    end
    -- Fallback to global installation (we installed it via npm)
    return { 'typescript-language-server', '--stdio' }
  end

  local root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'package.json', 'tsconfig.json' }, { upward = true })[1] or vim.fn.getcwd())

  vim.lsp.config('typescript', {
    cmd = get_typescript_lsp_cmd(),
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    root_dir = root_dir,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  })

  -- Enable TypeScript LSP
  vim.lsp.enable('typescript')
end

-- Set up TypeScript LSP after Mason is ready
vim.api.nvim_create_autocmd('User', {
  pattern = 'MasonUpdateComplete',
  callback = setup_typescript_lsp,
  once = true,
})

-- Also try to set up immediately (in case Mason is already ready)
vim.defer_fn(function()
  if pcall(require, 'mason-registry') then
    setup_typescript_lsp()
  end
end, 1000)
-- ========================================================================== --
-- ==                            ESLINT LSP CONFIG                          == --
-- ========================================================================== --

local function setup_eslint_lsp()
  local function get_eslint_lsp_cmd()
    local ok, mason_registry = pcall(require, 'mason-registry')
    if ok and mason_registry.is_installed('eslint-lsp') then
      local eslint_lsp = mason_registry.get_package('eslint-lsp')
      if eslint_lsp then
        local success, install_path = pcall(function() return eslint_lsp:get_install_path() end)
        if success and install_path then
          return { install_path .. '/node_modules/.bin/vscode-eslint-language-server', '--stdio' }
        end
      end
    end
    -- Fallback to global installation
    return { 'vscode-eslint-language-server', '--stdio' }
  end

  local root_file = vim.fs.find({ '.git', 'package.json', '.eslintrc', '.eslintrc.js', '.eslintrc.json', '.eslintrc.cjs', '.eslintrc.mjs', 'eslint.config.js', 'eslint.config.mjs' }, { upward = true })[1]
  local root_dir = root_file and vim.fs.dirname(root_file) or vim.fn.getcwd()
  
  -- Ensure root_dir is always a valid string
  if not root_dir or root_dir == '' then
    root_dir = vim.fn.getcwd()
  end

  -- Only enable if we have a valid root_dir
  if root_dir and root_dir ~= '' and vim.fn.isdirectory(root_dir) == 1 then
    vim.lsp.config('eslint', {
      cmd = get_eslint_lsp_cmd(),
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
      root_dir = root_dir,
      settings = {
        eslint = {
          validate = 'on',
          codeAction = {
            disableRuleComment = {
              enable = true,
              location = 'separateLine',
            },
            showDocumentation = {
              enable = true,
            },
          },
        },
      },
    })

    -- Enable ESLint LSP
    vim.lsp.enable('eslint')
  end
end

-- Set up ESLint LSP after Mason is ready
vim.api.nvim_create_autocmd('User', {
  pattern = 'MasonUpdateComplete',
  callback = setup_eslint_lsp,
  once = true,
})

-- Also try to set up immediately (in case Mason is already ready)
vim.defer_fn(function()
  if pcall(require, 'mason-registry') then
    setup_eslint_lsp()
  end
end, 1000)


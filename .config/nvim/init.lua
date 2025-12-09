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

-- Debug command to check diagnostics
vim.api.nvim_create_user_command('CheckDiagnostics', function()
  local diags = vim.diagnostic.get(0)
  local eslint_diags = {}
  local ts_diags = {}
  for _, diag in ipairs(diags) do
    if diag.source == "eslint" or (diag.code and tostring(diag.code):match("import")) then
      table.insert(eslint_diags, diag)
    elseif diag.source == "typescript" or diag.source == "ts" then
      table.insert(ts_diags, diag)
    end
  end
  vim.notify(string.format("Total diagnostics: %d, TypeScript: %d, ESLint/import: %d", #diags, #ts_diags, #eslint_diags), vim.log.levels.INFO)
  if #eslint_diags > 0 then
    for _, diag in ipairs(eslint_diags) do
      vim.notify(string.format("  ESLint Line %d: %s (%s)", diag.lnum + 1, diag.message, diag.code or "no code"), vim.log.levels.INFO)
    end
  end
  if #ts_diags > 0 then
    for _, diag in ipairs(ts_diags) do
      vim.notify(string.format("  TypeScript Line %d: %s (%s)", diag.lnum + 1, diag.message, diag.code or "no code"), vim.log.levels.INFO)
    end
  end
end, {})

-- Command to check active LSP clients
vim.api.nvim_create_user_command('CheckLSPClients', function()
  local clients = vim.lsp.get_active_clients()
  local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
  vim.notify(string.format("Active clients: %d, Buffer clients: %d", #clients, #buf_clients), vim.log.levels.INFO)
  for _, client in ipairs(buf_clients) do
    vim.notify(string.format("  - %s (id: %d)", client.name, client.id), vim.log.levels.INFO)
  end
end, {})

-- Command to check null-ls sources
vim.api.nvim_create_user_command('CheckNullLSSources', function()
  local ok, null_ls = pcall(require, "null-ls")
  if not ok then
    vim.notify("null-ls not available", vim.log.levels.ERROR)
    return
  end
  
  local sources = null_ls.get_sources()
  vim.notify(string.format("null-ls sources: %d total", #sources), vim.log.levels.INFO)
  
  local formatting_sources = {}
  local diagnostic_sources = {}
  
  for _, source in ipairs(sources) do
    if source.method == null_ls.methods.FORMATTING then
      table.insert(formatting_sources, {
        name = source.name,
        filetypes = source.filetypes or {},
      })
    elseif source.method == null_ls.methods.DIAGNOSTICS then
      table.insert(diagnostic_sources, {
        name = source.name,
        filetypes = source.filetypes or {},
      })
    end
  end
  
  vim.notify(string.format("Formatting sources: %d", #formatting_sources), vim.log.levels.INFO)
  for _, src in ipairs(formatting_sources) do
    vim.notify(string.format("  - %s (filetypes: %s)", src.name, table.concat(src.filetypes, ", ")), vim.log.levels.INFO)
  end
  
  vim.notify(string.format("Diagnostic sources: %d", #diagnostic_sources), vim.log.levels.INFO)
  for _, src in ipairs(diagnostic_sources) do
    vim.notify(string.format("  - %s (filetypes: %s)", src.name, table.concat(src.filetypes, ", ")), vim.log.levels.INFO)
  end
end, {})

-- Command to test ESLint formatting manually
vim.api.nvim_create_user_command('TestESLintFormat', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo.filetype
  
  vim.notify(string.format("Testing ESLint format for: %s (filetype: %s)", filename or "unnamed", filetype), vim.log.levels.INFO)
  
  -- Check if null-ls is attached
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local null_ls_client = nil
  for _, client in ipairs(clients) do
    if client.name == "null-ls" then
      null_ls_client = client
      break
    end
  end
  
  if not null_ls_client then
    vim.notify("ERROR: null-ls client not attached to buffer", vim.log.levels.ERROR)
    return
  end
  
  vim.notify("null-ls client found, checking sources...", vim.log.levels.INFO)
  
  -- Check sources
  local null_ls = require("null-ls")
  local sources = null_ls.get_sources()
  local eslint_formatting = nil
  
  -- Look for any ESLint formatting source (builtin or custom)
  for _, source in ipairs(sources) do
    if source.method == null_ls.methods.FORMATTING then
      local name = source.name or ""
      if name == "eslint_fix" or name == "eslint_d" or name == "eslint" then
        eslint_formatting = source
        vim.notify(string.format("Found ESLint formatting source: %s", name), vim.log.levels.INFO)
        break
      end
    end
  end
  
  if not eslint_formatting then
    vim.notify("ERROR: ESLint formatting source not found. Available formatting sources:", vim.log.levels.ERROR)
    for _, source in ipairs(sources) do
      if source.method == null_ls.methods.FORMATTING then
        vim.notify(string.format("  - %s", source.name or "unknown"), vim.log.levels.INFO)
      end
    end
    return
  end
  
  vim.notify(string.format("ESLint source found (%s), checking runtime condition...", eslint_formatting.name), vim.log.levels.INFO)
  
  -- Check runtime condition (custom sources use generator_opts.runtime_condition, builtins use condition)
  local should_run = true
  if eslint_formatting.generator_opts and eslint_formatting.generator_opts.runtime_condition then
    local params = {
      bufnr = bufnr,
      bufname = filename,
      filename = filename,
    }
    should_run = eslint_formatting.generator_opts.runtime_condition(params)
    vim.notify(string.format("Runtime condition (generator_opts) result: %s", should_run and "PASS" or "FAIL"), vim.log.levels.INFO)
  elseif eslint_formatting._opts and eslint_formatting._opts.condition then
    -- Builtin formatters use condition
    should_run = eslint_formatting._opts.condition()
    vim.notify(string.format("Runtime condition (builtin) result: %s", should_run and "PASS" or "FAIL"), vim.log.levels.INFO)
  else
    vim.notify("No runtime condition found, will attempt to run", vim.log.levels.INFO)
  end
  
  if not should_run then
    vim.notify("Runtime condition failed - ESLint won't run. Check eslint config and executable.", vim.log.levels.WARN)
    return
  end
  
  vim.notify("Attempting to format with ESLint...", vim.log.levels.INFO)
  
  -- Try to format
  local success, err = pcall(function()
    vim.lsp.buf.format({
      bufnr = bufnr,
      filter = function(client)
        return client.name == "null-ls"
      end,
      async = false,
    })
  end)
  
  if success then
    vim.notify("ESLint format completed successfully", vim.log.levels.INFO)
  else
    vim.notify(string.format("ESLint format error: %s", err), vim.log.levels.ERROR)
  end
end, {})

-- Command to manually test ESLint autofix directly (bypasses null-ls)
vim.api.nvim_create_user_command('TestESLintDirect', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  
  if not filename or filename == "" then
    vim.notify("No file name", vim.log.levels.ERROR)
    return
  end
  
  -- Find eslint
  local root_file = vim.fs.find({ "package.json", "node_modules" }, { upward = true, path = filename })[1]
  if not root_file then
    vim.notify("No package.json or node_modules found", vim.log.levels.ERROR)
    return
  end
  
  local root = vim.fs.dirname(root_file)
  local eslint_cmd = root .. "/node_modules/.bin/eslint"
  
  if vim.fn.executable(eslint_cmd) ~= 1 then
    vim.notify(string.format("ESLint not found at: %s", eslint_cmd), vim.log.levels.ERROR)
    return
  end
  
  -- Get relative path from project root
  local relative_path = filename:gsub("^" .. root .. "/", "")
  
  vim.notify(string.format("Running: %s --fix %s (from %s)", eslint_cmd, relative_path, root), vim.log.levels.INFO)
  
  -- Change to project root and run ESLint
  local old_cwd = vim.fn.getcwd()
  vim.fn.chdir(root)
  
  -- Run ESLint with relative path
  local result = vim.fn.system({ eslint_cmd, "--fix", relative_path })
  local exit_code = vim.v.shell_error
  
  -- Restore original directory
  vim.fn.chdir(old_cwd)
  
  if exit_code == 0 then
    vim.notify("ESLint autofix completed successfully", vim.log.levels.INFO)
    -- Reload buffer to see changes
    vim.cmd("edit")
  else
    vim.notify(string.format("ESLint exited with code %d: %s", exit_code, result), vim.log.levels.ERROR)
  end
end, {})

-- Test ESLint with stdin (like null-ls does)
vim.api.nvim_create_user_command('TestESLintStdin', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  
  if not filename or filename == "" then
    vim.notify("No file name", vim.log.levels.ERROR)
    return
  end
  
  -- Find eslint
  local root_file = vim.fs.find({ "package.json", "node_modules" }, { upward = true, path = filename })[1]
  if not root_file then
    vim.notify("No package.json or node_modules found", vim.log.levels.ERROR)
    return
  end
  
  local root = vim.fs.dirname(root_file)
  local eslint_cmd = root .. "/node_modules/.bin/eslint"
  
  if vim.fn.executable(eslint_cmd) ~= 1 then
    vim.notify(string.format("ESLint not found at: %s", eslint_cmd), vim.log.levels.ERROR)
    return
  end
  
  -- Get buffer content
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  vim.notify(string.format("Testing ESLint with stdin for: %s", filename), vim.log.levels.INFO)
  
  -- Change to project root
  local old_cwd = vim.fn.getcwd()
  vim.fn.chdir(root)
  
  -- Run ESLint with stdin
  local result = vim.fn.system({ eslint_cmd, "--fix", "--stdin", "--stdin-filename", filename }, content)
  local exit_code = vim.v.shell_error
  
  -- Restore original directory
  vim.fn.chdir(old_cwd)
  
  if exit_code <= 1 then
    if result and #result > 0 then
      vim.notify(string.format("ESLint returned fixed code (%d chars). Exit code: %d", #result, exit_code), vim.log.levels.INFO)
      -- Show first 200 chars of output
      local preview = result:sub(1, 200)
      vim.notify(string.format("Output preview: %s...", preview), vim.log.levels.INFO)
    else
      vim.notify(string.format("ESLint returned no output. Exit code: %d", exit_code), vim.log.levels.WARN)
    end
  else
    vim.notify(string.format("ESLint exited with code %d: %s", exit_code, result), vim.log.levels.ERROR)
  end
end, {})

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
        -- Configure diagnostics to show in signcolumn and via tiny-inline-diagnostic
        vim.diagnostic.config({
          virtual_text = false, -- Disable Neovim's default virtual text (tiny-inline-diagnostic handles this)
          signs = true, -- Show signs in signcolumn
          underline = true, -- Underline errors
          update_in_insert = false, -- Don't update diagnostics while typing
          severity_sort = true, -- Sort by severity
          -- Show diagnostics from all sources (TypeScript LSP, ESLint, etc.)
          sources = nil, -- nil means show all sources
        })
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

      -- Helper to find prettier executable (prefers prettierd, then local, then global)
      local function find_prettier()
        -- Try prettierd first
        if vim.fn.executable("prettierd") == 1 then
          return "prettierd"
        end
        
        -- Try local prettierd
        local root_file = vim.fs.find({ "package.json", "node_modules" }, { upward = true })[1]
        if root_file then
          local root = vim.fs.dirname(root_file)
          local local_prettierd = root .. "/node_modules/.bin/prettierd"
          if vim.fn.executable(local_prettierd) == 1 then
            return local_prettierd
          end
          local local_prettier = root .. "/node_modules/.bin/prettier"
          if vim.fn.executable(local_prettier) == 1 then
            return local_prettier
          end
        end
        
        -- Fallback to global prettier
        return "prettier"
      end

      prettier.setup({
        bin = find_prettier(),
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

    end,
  },

  { -- null-ls (none-ls.nvim): ESLint autofix
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      local helpers = require("null-ls.helpers")
      local builtins = null_ls.builtins

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

      local sources = {}

      -- Always register ESLint sources (runtime_condition will handle whether to run)
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
            format = "raw",  -- Use raw to handle JSON parsing ourselves
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
      -- Try using builtin eslint formatter first, then fall back to custom
      local eslint_formatting_source = nil
      
      -- Check if builtin eslint formatter exists
      vim.notify("Checking for builtin ESLint formatters...", vim.log.levels.INFO)
      if builtins.formatting then
        vim.notify(string.format("builtins.formatting exists, checking eslint_d and eslint..."), vim.log.levels.INFO)
        if builtins.formatting.eslint_d then
          vim.notify("Found builtin eslint_d formatter", vim.log.levels.INFO)
          -- Use builtin eslint_d and configure it
          eslint_formatting_source = builtins.formatting.eslint_d.with({
            condition = function(utils)
              return utils.root_has_file({
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.json",
                ".eslintrc.cjs",
                ".eslintrc.mjs",
                "eslint.config.js",
                "eslint.config.mjs"
              })
            end,
            prefer_local = "node_modules/.bin",
          })
          vim.notify("Using builtin eslint_d formatter", vim.log.levels.INFO)
        elseif builtins.formatting.eslint then
          vim.notify("Found builtin eslint formatter", vim.log.levels.INFO)
          -- Use builtin eslint and configure it
          eslint_formatting_source = builtins.formatting.eslint.with({
            condition = function(utils)
              return utils.root_has_file({
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.json",
                ".eslintrc.cjs",
                ".eslintrc.mjs",
                "eslint.config.js",
                "eslint.config.mjs"
              })
            end,
            prefer_local = "node_modules/.bin",
          })
          vim.notify("Using builtin eslint formatter", vim.log.levels.INFO)
        else
          vim.notify("No builtin eslint or eslint_d formatter found", vim.log.levels.INFO)
        end
      else
        vim.notify("builtins.formatting does not exist", vim.log.levels.WARN)
      end
      
      if not eslint_formatting_source then
        vim.notify("Creating custom ESLint formatter...", vim.log.levels.INFO)
        -- Fall back to custom formatter using make_builtin
        local success, result = pcall(function()
          return helpers.make_builtin({
            name = "eslint_fix",
            meta = {
              url = "https://eslint.org/",
              description = "ESLint autofix",
            },
            method = null_ls.methods.FORMATTING,
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            generator_opts = {
              command = function(params)
                local filename = params.bufname or params.filename or vim.api.nvim_buf_get_name(params.bufnr or 0)
                return find_eslint(filename)
              end,
              runtime_condition = function(params)
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
                  local eslint_cmd = find_eslint(filename)
                  local executable = eslint_cmd and vim.fn.executable(eslint_cmd) == 1
                  vim.notify(string.format("[ESLint runtime_condition] filename=%s, config=%s, cmd=%s, executable=%s, result=%s", 
                    filename or "nil", 
                    root_file or "nil", 
                    eslint_cmd or "nil", 
                    executable and "YES" or "NO",
                    executable and "PASS" or "FAIL"
                  ), vim.log.levels.DEBUG)
                  return executable
                else
                  vim.notify(string.format("[ESLint runtime_condition] No eslint config found for: %s", filename or "nil"), vim.log.levels.DEBUG)
                end
                return false
              end,
              -- ESLint doesn't support --fix with --stdin, so we use a temp file approach
              -- Write stdin to temp file, run ESLint --fix, then output the result
              command = function(params)
                return "sh"
              end,
              args = function(params)
                local filename = params.bufname or params.filename or vim.api.nvim_buf_get_name(params.bufnr or 0)
                local eslint_cmd = find_eslint(filename)
                local ext = filename:match("%.([^%.]+)$") or "tsx"
                -- Get project root for temp file location
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
                local project_root = root_file and vim.fs.dirname(root_file) or "/tmp"
                -- Shell script: write stdin to temp file in project dir, fix it, output ONLY the file content, clean up
                -- Redirect ESLint's stdout/stderr to /dev/null, then output only the fixed file
                local script = string.format(
                  'TMP=$(mktemp "%s/eslint-fix-XXXXXX.%s") && cat > "$TMP" && "%s" --fix "$TMP" >/dev/null 2>&1 && cat "$TMP" && rm -f "$TMP"',
                  project_root,
                  ext,
                  eslint_cmd:gsub('"', '\\"') -- Escape quotes in path
                )
                return { "-c", script }
              end,
              to_stdin = true,
              check_exit_code = function(code)
                -- ESLint exits with 0 (no issues), 1 (issues found but some fixed), or 2 (fatal error)
                -- We should accept 0 and 1 (fixes applied)
                return code <= 1
              end,
              cwd = function(params)
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
          })
        end)
        
        if success and result then
          eslint_formatting_source = result
          vim.notify("Using custom eslint formatter", vim.log.levels.INFO)
        else
          vim.notify(string.format("ERROR: Failed to create ESLint formatting source: %s", tostring(result)), vim.log.levels.ERROR)
        end
      end
      
      if eslint_formatting_source then
        -- Debug: Inspect source structure
        vim.notify(string.format("ESLint source structure - name: %s, method: %s, filetypes: %s", 
          eslint_formatting_source.name or "nil",
          eslint_formatting_source.method and tostring(eslint_formatting_source.method) or "nil",
          eslint_formatting_source.filetypes and table.concat(eslint_formatting_source.filetypes, ",") or "nil"
        ), vim.log.levels.INFO)
        
        table.insert(sources, eslint_formatting_source)
        vim.notify(string.format("ESLint formatting source registered: %s", eslint_formatting_source.name or "unknown"), vim.log.levels.INFO)
      end

      vim.notify(string.format("Registering %d null-ls sources", #sources), vim.log.levels.INFO)
      
      -- Log all sources being registered
      for i, source in ipairs(sources) do
        local source_info = string.format("Source %d: name=%s, method=%s, filetypes=%s", 
          i, 
          source.name or "nil",
          source.method and tostring(source.method) or "nil",
          source.filetypes and table.concat(source.filetypes, ",") or "nil"
        )
        vim.notify(source_info, vim.log.levels.INFO)
      end
      
      null_ls.setup({
        sources = sources,
        -- Increase timeout for ESLint which can be slow
        default_timeout = 30000, -- 30 seconds
      })
      
      -- Verify sources were registered
      vim.defer_fn(function()
        local registered_sources = null_ls.get_sources()
        vim.notify(string.format("null-ls setup completed. %d sources registered.", #registered_sources), vim.log.levels.INFO)
        for _, src in ipairs(registered_sources) do
          if src.method == null_ls.methods.FORMATTING then
            vim.notify(string.format("  Formatting: %s (filetypes: %s)", src.name, table.concat(src.filetypes or {}, ",")), vim.log.levels.INFO)
          end
        end
      end, 100)
    end,
  }
})

-- ========================================================================== --
-- ==                    PRETTIER + ESLINT FORMAT ON SAVE                 == --
-- ========================================================================== --

-- Format on save for JS/TS files: ESLint autofix first, then Prettier
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function(args)
    local bufnr = args.buf
    local filename = vim.api.nvim_buf_get_name(bufnr)
    
    -- Debug: Log format-on-save trigger
    vim.notify(string.format("[FormatOnSave] Triggered for: %s", filename or "unnamed"), vim.log.levels.DEBUG)
    
    -- Run ESLint autofix via null-ls
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local has_null_ls = false
    local null_ls_client = nil
    for _, client in ipairs(clients) do
      if client.name == "null-ls" then
        has_null_ls = true
        null_ls_client = client
        break
      end
    end
    
    vim.notify(string.format("[FormatOnSave] Found %d LSP clients, null-ls: %s", #clients, has_null_ls and "YES" or "NO"), vim.log.levels.DEBUG)
    
    if has_null_ls then
      -- Check null-ls sources using the proper API
      local null_ls = require("null-ls")
      local filetype = vim.bo[bufnr].filetype
      
      vim.notify(string.format("[FormatOnSave] Checking sources for filetype: %s", filetype), vim.log.levels.DEBUG)
      
      -- Get formatting sources directly using the method filter
      local formatting_sources = null_ls.get_sources({ method = null_ls.methods.FORMATTING })
      local all_sources = null_ls.get_sources()
      
      vim.notify(string.format("[FormatOnSave] Found %d formatting sources (out of %d total)", #formatting_sources, #all_sources), vim.log.levels.DEBUG)
      
      -- Check which formatting sources match this filetype
      -- Filetypes are stored as a table with boolean values, not an array
      local matching_sources = {}
      for _, source in ipairs(formatting_sources) do
        local source_name = source.name or "unknown"
        local source_filetypes = source.filetypes or {}
        local matches = false
        
        -- Check if filetype is in the filetypes table (it's a table with boolean values)
        if type(source_filetypes) == "table" then
          matches = source_filetypes[filetype] == true
        end
        
        if matches then
          table.insert(matching_sources, source_name)
        end
        
        vim.notify(string.format("[FormatOnSave]   Formatting source: %s (matches %s: %s)", 
          source_name,
          filetype,
          matches and "YES" or "NO"
        ), vim.log.levels.DEBUG)
      end
      
      if #matching_sources > 0 then
        vim.notify(string.format("[FormatOnSave] Matching formatting sources: %s", table.concat(matching_sources, ", ")), vim.log.levels.DEBUG)
      end
      
      -- Check if null-ls can format this buffer
      local can_format = null_ls_client.supports_method("textDocument/formatting")
      vim.notify(string.format("[FormatOnSave] null-ls supports formatting: %s", can_format and "YES" or "NO"), vim.log.levels.DEBUG)
      
      if not can_format then
        vim.notify("[FormatOnSave] null-ls does not support formatting for this buffer", vim.log.levels.WARN)
      end
      
      -- Try to format - null-ls will handle source selection automatically
      local success, err = pcall(function()
        -- Get buffer content before formatting to detect changes
        local lines_before = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        
        -- Format with null-ls (includes both eslint_fix and prettier)
        -- Note: prettier source is auto-detected by null-ls, not explicitly registered
        vim.lsp.buf.format({
          bufnr = bufnr,
          filter = function(client)
            return client.name == "null-ls"
          end,
          async = false,
        })
        
        -- Check if content changed
        local lines_after = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local changed = #lines_before ~= #lines_after
        if not changed then
          for i, line in ipairs(lines_before) do
            if lines_after[i] ~= line then
              changed = true
              break
            end
          end
        end
        
        if changed then
          vim.notify("[FormatOnSave] ESLint autofix completed - buffer was modified", vim.log.levels.INFO)
        else
          vim.notify("[FormatOnSave] ESLint autofix completed - no changes detected", vim.log.levels.DEBUG)
        end
      end)
      
      if not success then
        vim.notify(string.format("[FormatOnSave] Format error: %s", err), vim.log.levels.ERROR)
      end
    else
      vim.notify("[FormatOnSave] null-ls client not found, skipping ESLint autofix", vim.log.levels.WARN)
    end

    -- Run Prettier
    -- local prettier = require("prettier")
    -- prettier.format()
    -- vim.notify("[FormatOnSave] Prettier completed", vim.log.levels.DEBUG)
  end,
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
        -- Ensure TypeScript validation doesn't interfere with ESLint
        validate = true,
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
        -- Ensure JavaScript validation doesn't interfere with ESLint
        validate = true,
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


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

-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
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

  -- Editing enhancements
  'nvim-pack/nvim-spectre',
  'christoomey/vim-tmux-navigator',
  'AndrewRadev/tagalong.vim',
  {
    'windwp/nvim-autopairs',
    config = function()
      require("nvim-autopairs").setup({})
    end
  },
  {
    'windwp/nvim-ts-autotag',
    config = function ()
      require("nvim-ts-autotag").setup({})
    end
  },

  {
    'folke/zen-mode.nvim',
    config = function()
      require("zen-mode").setup({
        window = {
          height = .8,
          options = {
            number = false,
            relativenumber = false
          }
        },
        options = {
          enabled = true,
          ruler = true, -- disables the ruler text in the cmd line area
          showcmd = true, -- disables the command in the last line of the screen
        },
        plugins = {
          tmux = {
            enabled = true
          }
        }
      })
    end
  },
  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      "jose-elias-alvarez/null-ls.nvim",
      "jose-elias-alvarez/typescript.nvim",

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  -- Git enhancements
  'junegunn/gv.vim',
  { -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup{
        on_attach = function(bufnr)
              local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
          
    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})
        end
      }
    end
  },

  { -- Theme
    'haishanh/night-owl.vim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'night-owl'
    end,
  },

  { -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    },
  },

  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    config = function ()
      require('Comment').setup()
    end
  },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', version = '*', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  },

  -- asynctasks
  'scottyeck/asynctasks.vim',
  'skywind3000/asyncrun.vim',
  'skywind3000/asyncrun.extra',
  'preservim/vimux',
  'GustavoKatel/telescope-asynctasks.nvim',

  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
    "benfowler/telescope-luasnip.nvim",
  }
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  --
  --    An additional note is that if you only copied in the `init.lua`, you can just comment this line
  --    to get rid of the warning telling you that there are not plugins in `lua/custom/plugins/`.
  -- { import = 'custom.plugins' },
}, {})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local telescope_actions = require "telescope.actions"
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-q>'] = telescope_actions.smart_add_to_qflist + telescope_actions.open_qflist,
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'luasnip')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<C-p>', require('telescope.builtin').git_files, { desc = 'Ctrl-p' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fw', require('telescope.builtin').grep_string, { desc = '[F]ind current [W]ord' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fd', require('telescope.builtin').diagnostics, { desc = '[F]ind [D]iagnostics' })


vim.keymap.set('n', '<leader>ft', require('telescope').extensions.asynctasks.all, { desc = '[F]ind [T]asks' })
vim.keymap.set('n', '<leader>fs', require('telescope').extensions.luasnip.luasnip, { desc = '[F]ind [S]nippets' })

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function checkout_recency()
  pickers.new({
    results_title = "Git Checkout, <CR> to Checkout",
    finder = finders.new_oneshot_job({ "git", "branch", "--sort=-committerdate" }),
    sorter = sorters.get_fuzzy_file(),
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local branch_name = ""
        for segment in selection.value:gmatch("%S+") do
          if (segment ~= "*") then
            branch_name = segment
          end
        end
        vim.api.nvim_command(
          ":!git checkout " .. branch_name
        )
      end)
      return true
    end
  }):find()
end

vim.keymap.set('n', '<leader>gb', checkout_recency, { desc = '[G]it checkout [B]ranch ' })

-- [[ Configure Spectre ]]

vim.keymap.set('n', '<leader>S', require('spectre').open, { desc = '[S]pectre' })
vim.keymap.set('n', '<leader>sw', function ()
  require('spectre').open_visual({ select_word = true })
end, { desc = '[S]pectre [W]ord'})
-- TODO: Add these missing maps
-- vnoremap <leader>s <esc>:lua require('spectre').open_visual()<CR>
-- "  search in current file
-- nnoremap <leader>sp viw:lua require('spectre').open_file_search()<cr>

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'help', 'vim' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true, disable = { 'python' } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

---
-- Mason.nvim
---
-- See :help mason-settings
require('mason').setup({
  ui = { border = 'rounded' }
})

-- See :help mason-lspconfig-settings
require('mason-lspconfig').setup({
  ensure_installed = {
    'tsserver',
    'eslint',
    'html',
    'cssls'
  }
})

---
-- LSP config
---
-- See :help lspconfig-global-defaults
local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

---
-- Diagnostic customization
---
local sign = function(opts)
  -- See :help sign_define()
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({ name = 'DiagnosticSignError', text = '✘' })
sign({ name = 'DiagnosticSignWarn', text = '▲' })
sign({ name = 'DiagnosticSignHint', text = '⚑' })
sign({ name = 'DiagnosticSignInfo', text = '' })

-- See :help vim.diagnostic.config()
vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = 'rounded' }
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = 'rounded' }
)

---
-- null-ls
---

local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
  autostart = true,
  debug = false,
  sources = {
    formatting.prettier,
    formatting.shfmt.with({
      extra_args = { "-i", "2" }
    }),
    -- formatting.stylua
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})

---
-- LSP Keybindings
---
vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = { buffer = true }
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- You can search each function in the help page.
    -- For example :help vim.lsp.buf.hover()

    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<cr>')
    bufmap('n', 'gR', '<cmd>lua vim.lsp.buf.references()<cr>')
    bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
    bufmap('n', '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')
    bufmap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
    bufmap('n', '[a', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
    bufmap('n', ']a', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  end
})

vim.keymap.set('n', '<leader>af', ':EslintFixAll<CR>')

---
-- LSP servers
---
-- See :help mason-lspconfig-dynamic-server-setup
require('mason-lspconfig').setup_handlers({
  function(server)
    -- See :help lspconfig-setup
    lspconfig[server].setup({})
  end,
  ['tsserver'] = function()
    -- Note that we're configuring typescript.nvim here as it will
    -- intercept and handle tsserver for us.
    -- @see https://github.com/jose-elias-alvarez/typescript.nvim/issues/21#issuecomment-1344435540
    require("typescript").setup({
      settings = {
        completions = {
          completeFunctionCalls = true
        }
      }
    })
  end
})

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

luasnip.filetype_extend("typescriptreact", { "typescript" })

-- Because no path is specified, the "/snippets" dir will be use.
require('luasnip.loaders.from_snipmate').lazy_load()
-- To support friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs( -4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable( -1) then
        luasnip.jump( -1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

---
-- Git customization
---

-- command! Gwip !git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"
-- command! Gunwip !git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1
-- command! Gyank .GBrowse!
-- command! Gcob :exec printf('!git checkout -b %s', input('Enter new branch name: '))
-- command! Ggsup :exec printf('!git branch --set-upstream-to=origin/%s %s', g:fugitive#head(), g:fugitive#head())
-- command! Gcobak :exec printf('!git checkout -b %s-bak', g:fugitive#head())

vim.api.nvim_create_user_command('Glo', 'Git log --oneline', {})
vim.api.nvim_create_user_command('Gwip', '!git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"', {})
vim.api.nvim_create_user_command('Gyank', '.GBrowse!', {})

-- Support for hub was dropped in vim-rhubarb as gh becomes the
-- primary GitHub CLI, so we override this functionality manually.
-- @see https://github.com/tpope/vim-rhubarb/commit/964d48fd11db7c3a3246885993319d544c7c6fd5
vim.g.fugitive_git_command = "hub"

---
-- asynctasks
---

-- Open quickfix window automatically
vim.g.asyncrun_open = 6
-- Open in a tmux pane
vim.g.asynctasks_term_pos = 'tmux'
-- Orientation corresponds to the direction the panes flow. In
-- this case, a 'horizontal' orientation creates a 'vertical'
-- pane split.
vim.g.VimuxOrientation = 'h'
-- Height is generic for 'size' - percentage of screen the
-- tmux pane should occupy.
vim.g.VimuxHeight = 33

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et


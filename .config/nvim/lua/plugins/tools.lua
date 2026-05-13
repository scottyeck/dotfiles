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
          ['.'] = 'actions.open_cmdline',
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

  -- CSV tools
  {
    'hat0uma/csvview.nvim',
    ft = { 'csv' },
    opts = {
      parser = { comments = { '#', '//' } },
      keymaps = {
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
        jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
        jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
        jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
        jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
      },
      view = {
        display_mode = 'border',
      },
    },
    config = function(_, opts)
      require('csvview').setup(opts)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'csv',
        callback = function()
          vim.opt_local.wrap = false
          vim.cmd('CsvViewEnable')
        end,
      })
    end,
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  },

  -- Git signs in the gutter + inline blame
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      -- Linked-worktree fix: gitsigns' Repo.get caches a Repo per gitdir. If the
      -- first caller (e.g. a fugitive buffer) doesn't supply a toplevel, gitsigns
      -- falls back to dirname(gitdir) — `.git/worktrees` — and git happily echoes
      -- that wrong path back as --show-toplevel. Every later attach for real files
      -- reuses the poisoned cache entry, so ls-files runs with --work-tree set to
      -- `.git/worktrees` and finds nothing → "Empty git obj" → no hunks.
      --
      -- Wrap Repo.get to detect the poison pattern (toplevel == dirname(gitdir))
      -- and rewrite the cached repo using the linked worktree's `gitdir` metadata
      -- file, which points to the real worktree's .git.
      local uv = vim.uv or vim.loop
      local repo_mod = require('gitsigns.git.repo')
      local original_get = repo_mod.get
      repo_mod.get = function(cwd, gitdir, toplevel)
        local repo, err = original_get(cwd, gitdir, toplevel)
        if repo and repo.gitdir and repo.toplevel == vim.fs.dirname(repo.gitdir) then
          local f = io.open(repo.gitdir .. '/gitdir', 'r')
          if f then
            local content = f:read('*a')
            f:close()
            local worktree_dotgit = content and vim.trim(content) or ''
            local real_toplevel = vim.fs.dirname(worktree_dotgit)
            if real_toplevel and real_toplevel ~= '' and uv.fs_stat(real_toplevel) then
              repo.toplevel = real_toplevel
              repo.detached = repo.gitdir ~= real_toplevel .. '/.git'
            end
          end
        end
        return repo, err
      end
    end,
    -- Override gitsigns highlight groups so changes are easier to spot.
    -- Re-applied on ColorScheme so a `:colorscheme` swap doesn't erase them.
    init = function()
      local function set_hls()
        -- Stronger backgrounds than gitsigns' default ~10% blend; used when linehl is on.
        vim.api.nvim_set_hl(0, 'GitSignsAddLn', { bg = '#1e3a1e' })
        vim.api.nvim_set_hl(0, 'GitSignsChangeLn', { bg = '#3a3a1e' })
        vim.api.nvim_set_hl(0, 'GitSignsDeleteLn', { bg = '#3a1e1e' })
        -- Bold colored line numbers (numhl) so the gutter stays readable at a glance.
        vim.api.nvim_set_hl(0, 'GitSignsAddNr', { fg = '#7fbf5f', bold = true })
        vim.api.nvim_set_hl(0, 'GitSignsChangeNr', { fg = '#bfbf5f', bold = true })
        vim.api.nvim_set_hl(0, 'GitSignsDeleteNr', { fg = '#bf5f5f', bold = true })
      end
      vim.api.nvim_create_autocmd('ColorScheme', { callback = set_hls })
      set_hls()
    end,
    opts = {
      debug_mode = true, -- enables :Gitsigns debug_messages
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '▁' },
        topdelete = { text = '▔' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      signs_staged_enable = true,
      signcolumn = true,
      numhl = true,
      linehl = false,
      word_diff = false,
      current_line_blame = false, -- toggle with <leader>gb
      current_line_blame_opts = {
        delay = 300,
      },
      -- Linked-worktree workaround: gitsigns falls back to `dirname(gitdir)` for the
      -- toplevel, which is wrong (`.git/worktrees`) for linked worktrees. Ask git
      -- directly for normal buffers, and skip URI/non-normal buffers entirely so
      -- gitsigns' bad fallback never runs for them. See the Repo.get monkey-patch
      -- in `config` for the defense-in-depth piece.
      _on_attach_pre = function(bufnr, callback)
        local name = vim.api.nvim_buf_get_name(bufnr)
        -- Skip empty, URI-style (fugitive://, oil://, etc.), or non-normal buffers.
        -- Calling callback({}) for these lets gitsigns fall back to dirname(gitdir),
        -- which is wrong for linked worktrees AND poisons its repo_cache for every
        -- real buffer that follows. `return` (no callback) aborts attach cleanly.
        if name == ''
          or name:find('://', 1, true)
          or vim.bo[bufnr].buftype ~= ''
        then
          return
        end
        local dir = vim.fs.dirname(name)
        vim.system(
          { 'git', '-C', dir, 'rev-parse', '--absolute-git-dir', '--show-toplevel' },
          { text = true },
          function(out)
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(bufnr) then return end
              if out.code ~= 0 then
                return
              end
              local lines = vim.split(out.stdout, '\n', { trimempty = true })
              callback({ gitdir = lines[1], toplevel = lines[2] })
            end)
          end
        )
      end,
    },
    keys = {
      { '<leader>gl', '<cmd>Gitsigns toggle_current_line_blame<cr>', desc = 'Toggle git blame' },
      { '<leader>gh', '<cmd>Gitsigns toggle_linehl<cr>', desc = 'Toggle git line highlight' },
      { '<leader>gw', '<cmd>Gitsigns toggle_word_diff<cr>', desc = 'Toggle git word diff' },
      { ']h', '<cmd>Gitsigns next_hunk<cr>', desc = 'Next hunk' },
      { '[h', '<cmd>Gitsigns prev_hunk<cr>', desc = 'Previous hunk' },
      { ']c', '/^<<<<<<<\\|^=======\\|^>>>>>>><cr>', desc = 'Next conflict marker' },
      { '[c', '?^<<<<<<<\\|^=======\\|^>>>>>>><cr>', desc = 'Previous conflict marker' },
      { '<leader>hp', '<cmd>Gitsigns preview_hunk<cr>', desc = 'Preview hunk' },
      { '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>', desc = 'Stage hunk' },
      { '<leader>hr', '<cmd>Gitsigns reset_hunk<cr>', desc = 'Reset hunk' },
    },
  },

  -- Find and replace
  {
    'nvim-pack/nvim-spectre',
    config = function()
      vim.keymap.set('n', '<leader>ss', '<cmd>lua require("spectre").toggle()<CR>', {
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

      -- night-owl's terminal_color_1 (#ab0300) is too dark for removed lines
      -- in terminal buffers (e.g. fugitive's `I` / `git add --patch`).
      vim.g.terminal_color_1 = '#ef5350'

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

  -- Markdown preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- Markdown table editing
  {
    "Kicamon/markdown-table-mode.nvim",
    ft = { "markdown" },
    config = function()
      require("markdown-table-mode").setup()
    end,
  },
}

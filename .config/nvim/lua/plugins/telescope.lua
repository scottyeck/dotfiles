-- Telescope: Fuzzy finder
return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-frecency.nvim',
  },
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
      extensions = {
        frecency = {
          show_unindexed = true,
          db_safe_mode = false,
          sorting_strategy = 'descending',
        },
      },
    })

    -- Enable telescope fzf native, if installed
    pcall(telescope.load_extension, 'fzf')
    telescope.load_extension('frecency')

    -- Keymaps
    vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', function()
      require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<C-p>', '<Cmd>Telescope frecency workspace=CWD<CR>', { desc = 'Find files (frecency)' })
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
        prompt_title = 'Recent Branches (<CR> checkout, <C-y> copy, <C-r> rebase, <C-m> merge)',
        finder = finders.new_table({
          results = branches,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          local function get_branch()
            local selection = action_state.get_selected_entry()
            return selection and selection[1] or nil
          end

          -- <CR> = checkout (default)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local branch = get_branch()
            if branch then vim.cmd('Git checkout ' .. branch) end
          end)

          -- <C-y> = yank to clipboard
          map('i', '<C-y>', function()
            actions.close(prompt_bufnr)
            local branch = get_branch()
            if branch then
              vim.fn.setreg('+', branch)
              vim.notify('Copied: ' .. branch)
            end
          end)

          -- <C-r> = rebase onto selected branch
          map('i', '<C-r>', function()
            actions.close(prompt_bufnr)
            local branch = get_branch()
            if branch then vim.cmd('Git rebase ' .. branch) end
          end)

          -- <C-m> = merge selected branch
          map('i', '<C-m>', function()
            actions.close(prompt_bufnr)
            local branch = get_branch()
            if branch then vim.cmd('Git merge ' .. branch) end
          end)

          return true
        end,
      }):find()
    end, { desc = '[G]it [B]ranches [R]ecent' })
  end,
}

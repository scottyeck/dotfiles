-- Tpope plugins
return {
  'tpope/vim-abolish',
  'tpope/vim-eunuch',
  {
    'tpope/vim-fugitive',
    config = function()
      vim.api.nvim_create_user_command('Glo', 'Git log --oneline', {})
      vim.api.nvim_create_user_command('Gwip',
        '!git add -A && git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"',
        {})

      local function find_conflict_hunk()
        local lnum = vim.fn.line('.')
        local total = vim.fn.line('$')

        local start_line
        for i = lnum, 1, -1 do
          if vim.fn.getline(i):match('^<<<<<<<') then
            start_line = i
            break
          end
        end
        if not start_line then return nil end

        local mid_line
        for i = start_line + 1, total do
          if vim.fn.getline(i):match('^=======') then
            mid_line = i
            break
          end
        end
        if not mid_line then return nil end

        local end_line
        for i = mid_line + 1, total do
          if vim.fn.getline(i):match('^>>>>>>>') then
            end_line = i
            break
          end
        end
        if not end_line then return nil end

        if lnum > end_line then return nil end
        return { s = start_line, m = mid_line, e = end_line }
      end

      local function conflict_resolve(side)
        local hunk = find_conflict_hunk()
        if not hunk then
          if vim.wo.diff and side ~= 'both' then
            vim.cmd(side == 'top' and 'diffget //2' or 'diffget //3')
            return
          end
          vim.notify('No conflict hunk under cursor', vim.log.levels.WARN)
          return
        end

        local buf = 0
        if side == 'top' then
          vim.api.nvim_buf_set_lines(buf, hunk.m - 1, hunk.e, false, {})
          vim.api.nvim_buf_set_lines(buf, hunk.s - 1, hunk.s, false, {})
        elseif side == 'bottom' then
          vim.api.nvim_buf_set_lines(buf, hunk.e - 1, hunk.e, false, {})
          vim.api.nvim_buf_set_lines(buf, hunk.s - 1, hunk.m, false, {})
        else
          vim.api.nvim_buf_set_lines(buf, hunk.e - 1, hunk.e, false, {})
          vim.api.nvim_buf_set_lines(buf, hunk.m - 1, hunk.m, false, {})
          vim.api.nvim_buf_set_lines(buf, hunk.s - 1, hunk.s, false, {})
        end
      end

      vim.keymap.set('n', '<leader>ci', function() conflict_resolve('top') end, { desc = '[C]onflict take [I]ncoming' })
      vim.keymap.set('n', '<leader>cc', function() conflict_resolve('bottom') end, { desc = '[C]onflict take [C]urrent' })
      vim.keymap.set('n', '<leader>cb', function() conflict_resolve('both') end, { desc = '[C]onflict take [B]oth' })

      -- GitHub link to current line (via vim-rhubarb :GBrowse; bang yanks to clipboard)
      vim.keymap.set('n', '<leader>gy', ':.GBrowse!<CR>', { desc = '[G]itHub [Y]ank URL' })
      vim.keymap.set('v', '<leader>gy', ":'<,'>GBrowse!<CR>", { desc = '[G]itHub [Y]ank URL (range)' })
      vim.keymap.set('n', '<leader>go', ':.GBrowse<CR>', { desc = '[G]itHub [O]pen in browser' })
      vim.keymap.set('v', '<leader>go', ":'<,'>GBrowse<CR>", { desc = '[G]itHub [O]pen in browser (range)' })

      -- Support for hub was dropped in vim-rhubarb as gh becomes the
      -- primary GitHub CLI, so we override this functionality manually.
      -- @see https://github.com/tpope/vim-rhubarb/commit/964d48fd11db7c3a3246885993319d544c7c6fd5
      vim.g.fugitive_git_command = "hub"
    end
  },
  'tpope/vim-rhubarb',
  'junegunn/gv.vim', -- Git commit browser (:GV)
  'tpope/vim-sleuth',
  'tpope/vim-surround',

  -- Rails/Ruby workflow
  'tpope/vim-rails',
  'tpope/vim-dispatch',

  -- Ruby helpers
  'AndrewRadev/splitjoin.vim',
  'jgdavey/vim-blockle',
}

-- Tpope plugins
return {
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

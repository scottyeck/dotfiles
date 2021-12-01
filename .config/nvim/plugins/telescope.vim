Plug 'tami5/sqlite.lua' " Frecency dependency

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-telescope/telescope-frecency.nvim'

function TelescopeSetup()
lua << EOF
telescope = require('telescope')
telescope.setup{
  extensions = {
    frecency = {
      -- db_root = "home/my_username/path/to/db_root",
      -- show_scores = false,
      show_unindexed = true,
      ignore_patterns = {"*.git/*", "*/tmp/*", "*/node_modules/*"},
      -- disable_devicons = false,
      workspaces = {
        ["coa"]    = "/Users/scottyeck/git/coa/coa",
        ["wiki"]    = "/Users/scottyeck/wiki",
        -- TODO: Limit to gitfiles
        ["dots"]    = "/Users/scottyeck",
      }
    }
  },
}
EOF
endfunction "/TelescopeSetup()

" Standard Ctrl-p
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>

" Project-search
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>

" TODO: Need a node_modules search and a node_modules file-search

" Find files using Telescope command-line sugar.
nnoremap <C-p> <cmd>lua require('telescope').extensions.frecency.frecency()<cr>
" nnoremap <C-p> <cmd>lua require('telescope.builtin').oldfiles()<cr>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fs <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

nnoremap <leader>vb <cmd>lua require('telescope.builtin').buffers()<cr>

nnoremap <leader>gb <cmd>lua require('telescope.builtin').git_branches()<cr>

augroup TelescopeSetup
  autocmd!
  autocmd User PlugLoaded call TelescopeSetup()
augroup END

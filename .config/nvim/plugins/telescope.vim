Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" Standard Ctrl-p
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>

" TODO: Set up MRU via https://github.com/nvim-telescope/telescope-frecency.nvim
" TODO: Need a node_modules search and a node_modules file-search

" Find files using Telescope command-line sugar.
nnoremap <C-p> <cmd>lua require('telescope.builtin').oldfiles()<cr>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fs <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <leader>vb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>gb <cmd>lua require('telescope.builtin').git_branches()<cr>


" Telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" Standard Ctrl-p
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>

" Project-search
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>

" TODO: Set up MRU via https://github.com/nvim-telescope/telescope-frecency.nvim
" TODO: Need a node_modules search and a node_modules file-search


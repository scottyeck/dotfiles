" Spectre
Plug 'windwp/nvim-spectre'

" # spectre
" @see https://github.com/windwp/nvim-spectre
" ====================================================================
nnoremap <leader>S :lua require('spectre').open()<CR>

" search current word
nnoremap <leader>sw :lua require('spectre').open_visual({select_word=true})<CR>
vnoremap <leader>s :lua require('spectre').open_visual()<CR>
" search in current file
nnoremap <leader>sp viw:lua require('spectre').open_file_search()<cr>


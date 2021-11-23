Plug 'vimwiki/vimwiki'

let g:vimwiki_list = [{ 'path': '~/wiki/',
                      \ 'syntax': 'markdown',
                      \ 'ext': '.md',
                      \ 'links_space_char': '-'}]

" Vim-wiki uses "-" to remove header levels, interfering with vim-vinegar,
" so we don't map.
nmap <Nop> <Plug>VimwikiRemoveHeaderLevel



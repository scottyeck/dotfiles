execute pathogen#infect()

" # .vimrc

" :)

" ------------------------------
" ## Settings
" ------------------------------

syntax on
filetype plugin indent on
colorscheme codeschool

" Line numbers
set number

" Tab size
autocmd Filetype js setlocal tabstop=2

" ------------------------------
" ## Plugins
" ------------------------------

" ### CtrlP

" - https://github.com/ctrlpvim/ctrlp.vim#basic-options
" - http://tmr08c.github.io/vim/2015/09/19/making-nerdtree-and-ctrlp-play-nice.html

" CtrlP search ignore respects .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" Tell CtrlP not to split when opening a file from NERDTree
let g:ctrlp_dont_split = 'NERD'

" ### NERDTree

" Open NerdTree on start if opened in a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"
" Maps NerdTreeToggle to Ctrl+b (mirrors VSCode)
map <C-b> :NERDTreeToggle<CR>

" ### vim-airline

" - http://joshldavis.com/2014/04/05/vim-tab-madness-buffers-vs-tabs/

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" ### ale

let g:ale_linters = {
\ 'javascript': ['eslint'],
\}


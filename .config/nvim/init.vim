" Line numbers
set relativenumber
set nu

" Tabs
" (May wish to set this to be file-dependent)
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set smartindent

" Disable swap
set noswapfile

" Background buffers
set hidden

" Open vertical splits to the right, not left
set splitright

" Search
set incsearch

set signcolumn=yes

" Ignores
set wildignore+=**/.git/*
set wildignore+=**/node_modules/*

set termguicolors

" Required for usage of nvim-compe
set completeopt=menuone,noselect

let mapleader="\<space>"

call plug#begin('~/.vim/plugged')

source ~/.config/nvim/plugins/lib.vim

source ~/.config/nvim/plugins/abolish.vim
source ~/.config/nvim/plugins/asynctasks.vim
source ~/.config/nvim/plugins/autopairs.vim
source ~/.config/nvim/plugins/commentary.vim
source ~/.config/nvim/plugins/compe.vim
source ~/.config/nvim/plugins/dispatch.vim
source ~/.config/nvim/plugins/eunuch.vim
source ~/.config/nvim/plugins/gruvbox.vim
source ~/.config/nvim/plugins/fugitive.vim
source ~/.config/nvim/plugins/fzf.vim
source ~/.config/nvim/plugins/goyo.vim
source ~/.config/nvim/plugins/gv.vim
source ~/.config/nvim/plugins/gitgutter.vim
source ~/.config/nvim/plugins/lspconfig.vim
source ~/.config/nvim/plugins/repeat.vim
source ~/.config/nvim/plugins/rsi.vim
source ~/.config/nvim/plugins/surround.vim
source ~/.config/nvim/plugins/sensible.vim
source ~/.config/nvim/plugins/tmux-navigator.vim
source ~/.config/nvim/plugins/todo.txt.vim
source ~/.config/nvim/plugins/treesitter.vim
source ~/.config/nvim/plugins/ultisnips.vim
source ~/.config/nvim/plugins/vimwiki.vim
source ~/.config/nvim/plugins/vinegar.vim

call plug#end()
doautocmd User PlugLoaded

" Git
" ====================================================================

" Prefer Vertical split for Gdiff (not fugitive-specific)
" @see https://github.com/tpope/vim-fugitive/issues/510
" @see https://github.com/thoughtbot/dotfiles/issues/655#issuecomment-605019271
set diffopt+=vertical

" Misc
" ====================================================================

command! Note :exec printf(':edit %s', system('note --file'))

" QOL
" ====================================================================

" Make Y behave like C / D
nnoremap Y y$

" Make double-<Esc> clear search highlights
" @see https://stackoverflow.com/a/19877212
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>

" Assume use of JSONC format for syntax highlighting
" @see https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file
autocmd FileType json syntax match Comment +\/\/.\+$+

" Center buffer on / search result
" NB: May wish to open folds
" NB: May wish to implement for quickfix
nnoremap n nzz
nnoremap N Nzz

" Maintain cursor position on linewise Join
nnoremap J mzJ`z

" Move visual selections
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Move current line
nnoremap <leader>j :m .+1

function! Open(url)
  silent execute '!open ' . a:url
  redraw!
endfunction

nnoremap gx viW"xy \| :call Open(@x)<CR>

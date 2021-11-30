" Personal nvim config
" @scottyeck - <scott.eckenthal@gmail.com>

" ==========================================================
" Sets
" ==========================================================

set expandtab
set tabstop=2 softtabstop=2
set shiftwidth=2
set smartindent
set hidden
set signcolumn=yes
set relativenumber
set nu
set title
set list
set ignorecase
set smartcase
set noswapfile
set splitright
set incsearch
set termguicolors
set completeopt=menuone,noselect " Required for usage of nvim-compe

set wildignore+=**/.git/*
set wildignore+=**/node_modules/*

" Prefer Vertical split for Gdiff (not fugitive-specific)
" @see https://github.com/tpope/vim-fugitive/issues/510
" @see https://github.com/thoughtbot/dotfiles/issues/655#issuecomment-605019271
set diffopt+=vertical

let mapleader="\<space>"

" ==========================================================
" Plugins
" ==========================================================

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
" source ~/.config/nvim/plugins/lspconfig.vim
source ~/.config/nvim/plugins/repeat.vim
source ~/.config/nvim/plugins/rsi.vim
source ~/.config/nvim/plugins/sensible.vim
source ~/.config/nvim/plugins/spectre.vim
source ~/.config/nvim/plugins/surround.vim
source ~/.config/nvim/plugins/telescope.vim
source ~/.config/nvim/plugins/tmux-navigator.vim
source ~/.config/nvim/plugins/todo.txt.vim
source ~/.config/nvim/plugins/treesitter.vim
source ~/.config/nvim/plugins/ultisnips.vim
source ~/.config/nvim/plugins/vimwiki.vim
source ~/.config/nvim/plugins/vinegar.vim

" TODO: Move this
Plug 'neovim/nvim-lspconfig'
Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
Plug 'jose-elias-alvarez/null-ls.nvim'

call plug#end()
doautocmd User PlugLoaded

" TODO: Move this
source ~/.config/nvim/lua/lsp/init.lua

" ==========================================================
" Keymaps
" ==========================================================

" Allow gf to open non-existent files
map gf :edit <cfile><cr>

nmap <leader>ve :edit ~/.config/nvim/init.vim<CR>
nmap <leader>vs :source ~/.config/nvim/init.vim<CR>

nmap <leader>Q :bufdo bdelete<CR>

nmap <leader>o :only<CR>

" Reselect visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" Make Y behave like C / D
nnoremap Y y$

" Make double-<Esc> clear search highlights
" @see https://stackoverflow.com/a/19877212
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>

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

" Open a URL
nnoremap gx viW"xy \| :call Open(@x)<CR>

" ==========================================================
" Misc
" ==========================================================

augroup FileTypeOverrides
  autocmd!
  " Assume use of JSONC format for syntax highlighting
  " @see https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file
  autocmd FileType json syntax match Comment +\/\/.\+$+
augroup END

command! Note :exec printf(':edit %s', system('note --file'))


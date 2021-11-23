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

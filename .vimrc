execute pathogen#infect()
syntax enable
" Enable filetype plugin detection under ~/.vim/ftplugin
" https://www.gilesorr.com/blog/vim-ftplugin.html
filetype plugin indent on

" # .vimrc

" :)

" ------------------------------
" ## Settings
" ------------------------------

" Note that colorscheme matches alacritty config
" @see https://github.com/morhetz/gruvbox
colorscheme gruvbox
set background=dark
" Enabled to prevent extra-yellow bg color in light mode
" @see https://github.com/morhetz/gruvbox/issues/300
set termguicolors

" Use zsh as shell inside vim
set shell=/bin/zsh

" Support relative & absolute numbers simultaneously.
" @see https://stackoverflow.com/a/61681958
set relativenumber
set number

" Tab size
set tabstop=2
set shiftwidth=2
set expandtab

" Open vertical splits to the right, not left
set splitright

let mapleader="\<space>"

" Specify spellcheck dict location
" @see https://www.ostechnix.com/use-spell-check-feature-vim-text-editor/
set spellfile=~/.vim/spell/en.utf-8.add

" Enable spell in git commits
" @see https://stackoverflow.com/a/19485184
autocmd FileType gitcommit setlocal spell

" thesaurus-query.vim
" Note that in order to use mthesaur_txt, you need to
" fetch a local copy of the Moby Thesaurus.
" curl http://www.gutenberg.org/files/3202/files/mthesaur.txt -O ~/.config/nvim/thesaurus/
" @see https://en.wikipedia.org/wiki/Moby_Project#Thesaurus
let g:tq_enabled_backends=["mthesaur_txt", "datamuse_com"]

" Activate Colorizer
" @see https://github.com/chrisbra/Colorizer/issues/56
let g:colorizer_auto_color = 1

" Highlight line in insert mode
" https://stackoverflow.com/a/6489348/2423549
" :autocmd InsertEnter * set cul
" :autocmd InsertLeave * set nocul

" Change cursor shape when switching between insert / normal mode
" https://stackoverflow.com/a/30199177/2423549
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Modify behaviors for opening windows in netrw - currently set
" to open in same window.
" @see https://groups.google.com/d/msg/vim_use/Gb_YeadW5FE/5wptj3orcSsJ
" @see https://vi.stackexchange.com/a/19924 (Previous settings)
let g:netrw_browse_split = 0

" Assume use of JSONC format for syntax highlighting
" @see https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file
autocmd FileType json syntax match Comment +\/\/.\+$+

" Make double-<Esc> clear search highlights
" @see https://stackoverflow.com/a/19877212
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>

" Set filetypes as typescript.tsx
" @see https://github.com/peitalin/vim-jsx-typescript
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx

let g:spotify_token=$SPOTIFY_VIM_TOKEN

" ------------------------------
" ## Mappings
" ------------------------------

" Switch between buffers with Ctrl
nnoremap <C-l> :bn<Cr> 
nnoremap <C-h> :bp<Cr> 

" Open terminal in vertical split
nnoremap <C-j> :vs\|:te<Cr>

" " Use escape in terminal mode because it's simpler
" tnoremap <Esc> <C-\><C-n>

" ------------------------------
" ## Plugins
" ------------------------------

" ### fzf.vim

" Re-map fzf to Ctrl-p with MRU bindings
nnoremap <C-p> :FilesMru<Cr>
" Another ctrl-p-esque helper
nnoremap <C-space> :Buffers<Cr>

" Respect gitignore / prefer ag
let $FZF_DEFAULT_COMMAND = 'ag --ignore-case --ignore ".git" --hidden --filename-pattern ""'

" Floating window
let g:fzf_layout = { 'window': { 'width': 0.8 , 'height': 0.8 } }

" Some helpful window mgmt with fzf search results
" @see https://github.com/JesseLeite/dotfiles/commit/e1e1cee2f11c26ad22b6e021bbdb62fc8aa07aec
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Make :Ag not match file names, only the file content
" @see https://github.com/junegunn/fzf.vim/issues/346
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Define :Rag command to allow for search in subdir
" @see https://github.com/junegunn/fzf.vim/issues/413#issuecomment-320197362
command! -bang -nargs=+ -complete=dir Rag call fzf#vim#ag_raw(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Sort branches by recency via :GCheckout
let g:fzf_checkout_git_options = '--sort=-committerdate'

" ### goyo.vim


" Show / hide tmux status line in zen mode
" @see https://github.com/junegunn/goyo.vim#callbacks

function! s:goyo_enter()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status off
  endif
endfunction

function! s:goyo_leave()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status on
  endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" ### vim-prettier

" Enable vim-prettier to run (async) in files without requiring the "@format" doc tag
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync

" ### linepulse.vim
" Used to find cursor
" @see https://github.com/maddisoj/linepulse

let g:linepulse_steps = 5
let g:linepulse_time = 150

" ### CamelCaseMotion.vim

" Use default mappings
" @see https://github.com/bkad/CamelCaseMotion
let g:camelcasemotion_key = '<leader>'

" ### vim-vinegar

" Delete netrw buffers when they're hidden
" (Related to netrw rather than vingegar)
" @see https://github.com/tpope/vim-vinegar/issues/13#issuecomment-47133890
autocmd FileType netrw setl bufhidden=delete

" ### vim-fugitive

" Prefer Vertical split for Gdiff (not fugitive-specific)
" @see https://github.com/tpope/vim-fugitive/issues/510
" @see https://github.com/thoughtbot/dotfiles/issues/655#issuecomment-605019271
if &diff
    set diffopt-=internal
    set diffopt+=vertical
endif

" Mimic zsh aliases
command! Gwip !git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"
command! Gunwip !git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1
command! Gco GCheckout
command! Gf Gfetch
command! Gyank .Gbrowse!
command! Gcob :exec printf('!git checkout -b %s', input('Enter new branch name: '))
command! Ggsup :exec printf('!git branch --set-upstream-to=origin/%s %s', g:fugitive#head(), g:fugitive#head())
command! Gcn :exec printf('!git commit --amend --verbose --no-edit')
command! Gcan :exec printf('!git commit --amend --verbose --no-edit --all')

command! Gcobak :exec printf('!git checkout -b %s-bak', g:fugitive#head())

command! Note :exec printf(':edit %s', system('note --file'))

" ### async-run / async-tasks
" @see https://github.com/skywind3000/asynctasks.vim#get-started

" Open quickfix window automatically
let g:asyncrun_open = 6

" Open in a tmux pane
let g:asynctasks_term_pos = 'tmux'

" ### vimux
" FYI The 'tmux' asynctasks_term_pos setting above executes
" using Vimux via asynctasks.extra.

" Orientation corresponds to the direction the panes flow. In
" this case, a 'horizontal' orientation creates a 'vertical'
" pane split.
let g:VimuxOrientation = "h"
" Height is generic for 'size' - percentage of screen the
" tmux pane should occupy.
let g:VimuxHeight = 33

" ### sonicpi.vim

let g:sonicpi_command = 'sonic_pi'
let g:sonicpi_send = ''
let g:sonicpi_stop = 'stop'
let g:vim_redraw = 1

" ### VSCode-like settings

" Shortcut to pop Task list
nnoremap <C-r><C-t> :CocList tasks<Cr>

" Support gx inside vim terminal buffers
function! Open(url)
  silent execute '!open ' . a:url
  redraw!
endfunction
autocmd BufEnter term://* nnoremap <buffer> gx viW"xy \| :call Open(@x)<CR>


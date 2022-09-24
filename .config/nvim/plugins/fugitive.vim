Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

" Mimic zsh aliases
command! Gwip !git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"
command! Gunwip !git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1
command! Gcho GCheckout
command! Gf Gfetch
command! Gyank .Gbrowse!
command! Glo Git log --oneline
command! Gcob :exec printf('!git checkout -b %s', input('Enter new branch name: '))
command! Ggsup :exec printf('!git branch --set-upstream-to=origin/%s %s', g:fugitive#head(), g:fugitive#head())
command! Gcn :exec printf('!git commit --amend --verbose --no-edit')
command! Gcan :exec printf('!git commit --amend --verbose --no-edit --all')
command! Gcobak :exec printf('!git checkout -b %s-bak', g:fugitive#head())

" Sort branches by recency via :GCheckout
let g:fzf_checkout_git_options = '--sort=-committerdate'

" Support for hub was dropped in vim-rhubarb as gh becomes the
" primary GitHub CLI, so we override this functionality manually.
" @see https://github.com/tpope/vim-rhubarb/commit/964d48fd11db7c3a3246885993319d544c7c6fd5
let g:fugitive_git_command = 'hub'


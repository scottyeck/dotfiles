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

" Search
set incsearch
set nohlsearch

set signcolumn=yes

" Ignores
set wildignore+=**/.git/*
set wildignore+=**/node_modules/*

set termguicolors

" Required for usage of nvim-compe
set completeopt=menuone,noselect

let mapleader="\<space>"

call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'

" Explore
Plug 'tpope/vim-vinegar'

" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim'
Plug 'junegunn/fzf'
Plug 'scottyeck/fzf-checkout.vim'

" Qol
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-sensible'
Plug 'bkad/CamelCaseMotion'

" Zen mode
Plug 'junegunn/goyo.vim'

" Tmux
Plug 'christoomey/vim-tmux-navigator'

" Lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" Treesitter
" Maintainers recommend updating parsers on update
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Tasks
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/asyncrun.extra'
Plug 'scottyeck/asynctasks.vim'
Plug 'preservim/vimux'

call plug#end()

" Colors
" ====================================================================

colorscheme gruvbox
let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_invert_selection='0'

" Git
" ====================================================================

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

" Sort branches by recency via :GCheckout
let g:fzf_checkout_git_options = '--sort=-committerdate'

" Fzf
" ====================================================================

" Floating window
let g:fzf_layout = { 'window': { 'width': 0.8 , 'height': 0.8 } }

" Telescope settings
" ====================================================================

" Standard Ctrl-p
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>

" Project-search
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>

" TODO: Set up MRU via https://github.com/nvim-telescope/telescope-frecency.nvim
" TODO: Need a node_modules search and a node_modules file-search

" LSP / Lint / Format
" ====================================================================

" TS dev setup via Jose Alvarez
" @see https://jose-elias-alvarez.medium.com/configuring-neovims-lsp-client-for-typescript-development-5789d58ea9c
" TODO: Consider usage of additional utils: https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils

lua << EOF
local lspconfig = require'lspconfig'

local format_async = function(err, _, result, _, bufnr)
  if err ~= nil or result == nil then return end
  if not vim.api.nvim_buf_get_option(bufnr, "modified") then
    local view = vim.fn.winsaveview()
    vim.lsp.util.apply_text_edits(result, bufnr)
    vim.fn.winrestview(view)
    if bufnr == vim.api.nvim_get_current_buf() then
      vim.api.nvim_command("noautocmd :update")
    end
  end
end

vim.lsp.handlers["textDocument/formatting"] = format_async

_G.lsp_organize_imports = function()
  local params = {
    command = "_typescript.organizeImports",
    arguments = {vim.api.nvim_buf_get_name(0)},
    title = ""
  }
  vim.lsp.buf.execute_command(params)
end

local on_attach = function(client, bufnr)
  local buf_map = vim.api.nvim_buf_set_keymap
  vim.cmd("command! LspDef lua vim.lsp.buf.definition()")
  vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")
  vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
  vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
  vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
  vim.cmd("command! LspOrganize lua lsp_organize_imports()")
  vim.cmd("command! LspRefs lua vim.lsp.buf.references()")
  vim.cmd("command! LspTypeDef lua vim.lsp.buf.type_definition()")
  vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
  vim.cmd("command! LspDiagPrev lua vim.lsp.diagnostic.goto_prev()")
  vim.cmd("command! LspDiagNext lua vim.lsp.diagnostic.goto_next()")
  vim.cmd("command! LspDiagLine lua vim.lsp.diagnostic.show_line_diagnostics()")
  vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")
  buf_map(bufnr, "n", "gd", ":LspDef<CR>", {silent = true})
  buf_map(bufnr, "n", "gr", ":LspRename<CR>", {silent = true})
  buf_map(bufnr, "n", "gR", ":LspRefs<CR>", {silent = true})
  buf_map(bufnr, "n", "gy", ":LspTypeDef<CR>", {silent = true})
  buf_map(bufnr, "n", "K", ":LspHover<CR>", {silent = true})
  buf_map(bufnr, "n", "gs", ":LspOrganize<CR>", {silent = true})
  buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>", {silent = true})
  buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>", {silent = true})
  buf_map(bufnr, "n", "ga", ":LspCodeAction<CR>", {silent = true})
  buf_map(bufnr, "n", "<Leader>a", ":LspDiagLine<CR>", {silent = true})
  buf_map(bufnr, "i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", {silent = true})

  if client.resolved_capabilities.document_formatting then
    vim.api.nvim_exec([[
     augroup LspAutocommands
         autocmd! * <buffer>
         autocmd BufWritePost <buffer> LspFormatting
     augroup END
     ]], true)
  end
end

lspconfig.tsserver.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end
}

local filetypes = {
  typescript = "eslint",
  typescriptreact = "eslint",
}

local linters = {
  eslint = {
    sourceName = "eslint",
    command = "eslint_d",
    rootPatterns = {".eslintrc.js", "package.json"},
    debounce = 100,
    args = {"--stdin", "--stdin-filename", "%filepath", "--format", "json"},
    parseJson = {
      errorsRoot = "[0].messages",
      line = "line",
      column = "column",
      endLine = "endLine",
      endColumn = "endColumn",
      message = "${message} [${ruleId}]",
      security = "severity"
    },
    securities = {[2] = "error", [1] = "warning"}
  }
}

local formatters = {
  prettier = {command = "prettier", args = {"--stdin-filepath", "%filepath"}}
}

local formatFiletypes = {
  javascript = "prettier",
  javascriptreact = "prettier",
  ["javascript.jsx"] = "prettier",
  typescript = "prettier",
  typescriptreact = "prettier",
  ["typescript.tsx"] = "prettier"
}

lspconfig.diagnosticls.setup {
  on_attach = on_attach,
  filetypes = vim.tbl_keys(filetypes),
  init_options = {
    filetypes = filetypes,
    linters = linters,
    formatters = formatters,
    formatFiletypes = formatFiletypes
  }
}

EOF

" Treesitter settings
" ====================================================================

lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}
EOF

" Nvim compe
" ====================================================================

" Recommended conventional compe setup via nvim-compe README.
" @see https://github.com/hrsh7th/nvim-compe

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.autocomplete = v:true
let g:compe.debug = v:false
let g:compe.min_length = 1
let g:compe.preselect = 'enable'
let g:compe.throttle_time = 80
let g:compe.source_timeout = 200
let g:compe.resolve_timeout = 800
let g:compe.incomplete_delay = 400
let g:compe.max_abbr_width = 100
let g:compe.max_kind_width = 100
let g:compe.max_menu_width = 100
let g:compe.documentation = v:true

let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.calc = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.nvim_lua = v:true
let g:compe.source.vsnip = v:true
let g:compe.source.ultisnips = v:true
let g:compe.source.luasnip = v:true
let g:compe.source.emoji = v:true

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

" # async-run / async-tasks
" @see https://github.com/skywind3000/asynctasks.vim#get-started
" ====================================================================

" Open quickfix window automatically
let g:asyncrun_open = 6

" Open in a tmux pane
let g:asynctasks_term_pos = 'tmux'

" Fzf integration
" @see https://github.com/skywind3000/asynctasks.vim/wiki/UI-Integration#fzf

function! s:fzf_sink(what)
	let p1 = stridx(a:what, '<')
	if p1 >= 0
		let name = strpart(a:what, 0, p1)
		let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
		if name != ''
			exec "AsyncTask ". fnameescape(name)
		endif
	endif
endfunction

function! s:fzf_task()
	let rows = asynctasks#source(&columns * 48 / 100)
	let source = []
	for row in rows
		let name = row[0]
		let source += [name . '  ' . row[1] . '  : ' . row[2]]
	endfor
	let opts = { 'source': source, 'sink': function('s:fzf_sink'),
				\ 'options': '+m --nth 1 --inline-info --tac' }
	if exists('g:fzf_layout')
		for key in keys(g:fzf_layout)
			let opts[key] = deepcopy(g:fzf_layout[key])
		endfor
	endif
	call fzf#run(opts)
endfunction

command! -nargs=0 AsyncTaskFzf call s:fzf_task()
nnoremap <C-r><C-t> :AsyncTaskFzf<Cr>

" ### vimux
" ====================================================================

" FYI The 'tmux' asynctasks_term_pos setting above executes
" using Vimux via asynctasks.extra.

" Orientation corresponds to the direction the panes flow. In
" this case, a 'horizontal' orientation creates a 'vertical'
" pane split.
let g:VimuxOrientation = "h"
" Height is generic for 'size' - percentage of screen the
" tmux pane should occupy.
let g:VimuxHeight = 33

" Misc
" ====================================================================

command! Note :exec printf(':edit %s', system('note --file'))


Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/asyncrun.extra'
Plug 'scottyeck/asynctasks.vim'
Plug 'preservim/vimux'

" @see https://github.com/skywind3000/asynctasks.vim#get-started

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
nnoremap <leader>rt :AsyncTaskFzf<Cr>

" FYI The 'tmux' asynctasks_term_pos setting above executes
" using Vimux via asynctasks.extra.

" Orientation corresponds to the direction the panes flow. In
" this case, a 'horizontal' orientation creates a 'vertical'
" pane split.
let g:VimuxOrientation = "h"
" Height is generic for 'size' - percentage of screen the
" tmux pane should occupy.
let g:VimuxHeight = 33


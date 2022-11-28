Plug 'haishanh/night-owl.vim', { 'as': 'night-owl' }

function NightOwlSetup()
  " Plugin does not support Tabline / Status bar out of the box
  " (as it assumes use of LightLine.vim), so we manually set.
  " Colors match those set via tmux-night-owl theme.
  " @see https://github.com/haishanh/night-owl.vim/issues/21
  " @see https://github.com/jsec/tmux-night-owl
  hi TabLineFill gui=none guibg=#011627
  hi TabLine gui=none guibg=#011627
  hi TabLineSel gui=bold guibg=#82aaff guifg=#011627
endfunction

augroup NightOwlSetup
  autocmd!
  autocmd User PlugLoaded ++nested colorscheme night-owl
  autocmd User PlugLoaded call NightOwlSetup()
augroup end


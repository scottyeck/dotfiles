Plug 'gruvbox-community/gruvbox'

" colorscheme gruvbox
set background=light
let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_invert_selection='0'


augroup GruvboxSetup
  autocmd!
  autocmd User PlugLoaded ++nested colorscheme gruvbox
augroup end

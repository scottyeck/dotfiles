Plug 'dracula/vim', { 'as': 'dracula' }

augroup DraculaSetup
  autocmd!
  autocmd User PlugLoaded ++nested colorscheme dracula
augroup end

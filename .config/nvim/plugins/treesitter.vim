" Maintainers recommend updating parsers on update
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'windwp/nvim-ts-autotag'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'

function TreesitterSetup()
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  -- Enables TS Autotag
  autotag = {
    enable = true,
  },
  -- Enables TS-context Commentstring
  context_commentstring = {
    enable = true
  }
}
EOF
endfunction

augroup TreesitterSetup
    autocmd!
    autocmd User PlugLoaded call TreesitterSetup()
augroup END

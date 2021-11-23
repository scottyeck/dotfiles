" Maintainers recommend updating parsers on update
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

function TreesitterSetup()
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}
EOF
endfunction

augroup TreesitterSetup
    autocmd!
    autocmd User PlugLoaded call TreesitterSetup()
augroup END

Plug 'windwp/nvim-autopairs'

function AutopairsSetup()
lua <<EOF
require("nvim-autopairs").setup{}
EOF
endfunction

augroup AutopairsSetup
  autocmd!
  autocmd User PlugLoaded call AutopairsSetup()
augroup END


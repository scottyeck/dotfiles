Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/trouble.nvim'

nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle lsp_workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle lsp_document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>

function TroubleSetup()
lua << EOF
  require('trouble')
EOF
endfunction "/TroubleSetup

augroup TroubleSetupGroup
  autocmd!
  autocmd User PlugLoaded call TroubleSetup()
augroup END

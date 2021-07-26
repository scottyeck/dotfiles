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

let mapleader="\<space>"

call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'

" Explore
Plug 'tpope/vim-vinegar'

" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

" Qol
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
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

" Telescope settings
" ====================================================================

" Standard Ctrl-p
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>

" Project-search
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>

" TODO: Set up MRU via https://github.com/nvim-telescope/telescope-frecency.nvim

" Lsp settings
" ====================================================================

lua << EOF
local lspconfig = require'lspconfig'

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

--local function eslint_config_exists()
--  local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)
--
--  if not vim.tbl_isempty(eslintrc) then
--    return true
--  end
--
--  if vim.fn.filereadable("package.json") then
--    if vim.fn.json_decode(vim.fn.readfile("package.json"))["eslintConfig"] then
--      return true
--    end
--  end
--
--  return false
--end

lspconfig.tsserver.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end
--  on_attach = function(client)
--    if client.config.flags then
--      client.config.flags.allow_incremental_sync = true
--    end
--    --client.resolved_capabilities.document_formatting = false
--    return true
--  end
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

--local eslint = {
--  lintCommand = "eslint_d -f visualstudio --stdin --stdin-filename ${INPUT}",
--  -- lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
--  lintIgnoreExitCode = true,
--  lintStdin = true,
--  lintFormats = {"%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m"},
--  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
--  formatStdin = true
--}
--  --formatCommand = "prettier_d_slim --stdin --stdin-filepath ${INPUT}",
--
--local prettier  = {
--  formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
--  formatStdin = true
--}
--
--local formatter = prettier
--local linter = eslint
--
-- lspconfig.efm.setup {
--   on_attach = function(client)
--    client.resolved_capabilities.document_formatting = true
--    client.resolved_capabilities.goto_definition = false
--    client.resolved_capabilities.code_action = true
--    return true
--  end,
--  root_dir = function()
--    if not eslint_config_exists() then
--      return nil
--    end
--    return vim.fn.getcwd()
--  end,
--  settings = {
--    languages = {
--      javascript = {formatter, linter},
--      javascriptreact = {formatter, linter},
--      ["javascript.jsx"] = {formatter, linter},
--      typescript = {formatter, linter},
--      ["typescript.tsx"] = {formatter, linter},
--      typescriptreact = {formatter, linter}
--    }
--  },
--  filetypes = {
--    "javascript",
--    "javascriptreact",
--    "javascript.jsx",
--    "typescript",
--    "typescript.tsx",
--    "typescriptreact"
--  },
--}

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

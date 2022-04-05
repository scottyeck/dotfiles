local Plug = vim.fn["plug#"]
Plug 'nvim-telescope/telescope.nvim'

local utils = require("utils")

-- TODO
-- utils.command("Files", find_files)

utils.command("Rg", "Telescope live_grep")
utils.command("BLines", "Telescope current_buffer_fuzzy_find")
utils.command("History", "Telescope oldfiles")
utils.command("Buffers", "Telescope buffers")
utils.command("BCommits", "Telescope git_bcommits")
utils.command("Commits", "Telescope git_commits")
utils.command("Branches", "Telescope git_branches")
utils.command("HelpTags", "Telescope help_tags")
utils.command("ManPages", "Telescope man_pages")

utils.nmap("<c-p>", "<cmd>History<CR>")
utils.nmap("<Leader>fs", "<cmd>Rg<CR>")
utils.nmap("<Leader>fh", "<cmd>HelpTags<CR>")
utils.nmap("<Leader>vb", "<cmd>Buffers<CR>")
utils.nmap("<Leader>gb", "<cmd>Branches<CR>")

utils.command("LspRef", "Telescope lsp_references")
utils.command("LspDef", "Telescope lsp_definitions")
utils.command("LspSym", "Telescope lsp_workspace_symbols")
utils.command("LspAct", "Telescope lsp_code_actions")
utils.command("LspRangeAct", "Telescope lsp_range_code_actions")


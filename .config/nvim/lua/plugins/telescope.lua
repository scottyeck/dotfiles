local utils = require("utils")

local find_files = function()
  local set = require("telescope.actions.set")
  local builtin = require("telescope.builtin")

  local opts = {
    attach_mappings = function(_, map)
      map("i", "<C-v>", function(prompt_bufnr)
        set.edit(prompt_bufnr, "Vsplit")
      end)

      map("i", "<C-s>", function(prompt_bufnr)
        set.edit(prompt_bufnr, "Split")
      end)

      -- edit file and matching test file in split
      map("i", "<C-f>", function(prompt_bufnr)
        set.edit(prompt_bufnr, "edit")
        require("config.commands").edit_test_file("Vsplit $FILE | wincmd w")
      end)

      return true
    end,
  }

  local is_git_project = pcall(builtin.git_files, opts)
  if not is_git_project then
    builtin.find_files(opts)
  end
end

utils.command("Files", find_files)
utils.command("Rg", "Telescope live_grep")
utils.command("BLines", "Telescope current_buffer_fuzzy_find")
utils.command("History", "Telescope oldfiles")
utils.command("GitFiles", "Telescope git_files")
utils.command("Buffers", "Telescope buffers")
utils.command("BCommits", "Telescope git_bcommits")
utils.command("Commits", "Telescope git_commits")
utils.command("Branches", "Telescope git_branches")
utils.command("HelpTags", "Telescope help_tags")
utils.command("ManPages", "Telescope man_pages")

utils.nmap("<c-p>", "<cmd>GitFiles<CR>")
utils.nmap("<Leader>fs", "<cmd>Rg<CR>")
utils.nmap("<Leader>fh", "<cmd>HelpTags<CR>")
utils.nmap("<Leader>vb", "<cmd>Buffers<CR>")
utils.nmap("<Leader>gb", "<cmd>Branches<CR>")

utils.command("LspRef", "Telescope lsp_references")
utils.command("LspDef", "Telescope lsp_definitions")
utils.command("LspSym", "Telescope lsp_workspace_symbols")
utils.command("LspAct", vim.lsp.buf.code_action)
utils.command("LspRangeAct", vim.lsp.buf.range_code_action)


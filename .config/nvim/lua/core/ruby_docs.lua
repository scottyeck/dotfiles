-- Ruby method docs for when LSP hover can't help - Ruby LSP has no type inference,
-- so `some_local.change` hovers empty. Two fallbacks:
--   lookup(): find every `def <name>` in the project + bundled gems, preview the doc comments
--   explain(): ask Claude, which can infer the receiver from the surrounding code
local M = {}

-- Method names can end in ? ! or =, which <cword> drops
local function method_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local init = 1
  while true do
    local s, e = line:find('[%w_]+[?!=]?', init)
    if not s then
      return nil
    end
    if col >= s and col <= e then
      return line:sub(s, e)
    end
    init = e + 1
  end
end

local function project_root(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local found = vim.fs.find({ 'Gemfile', '.git' }, { upward = true, path = vim.fs.dirname(path) })[1]
  return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

-- `bundle list --paths` takes a second or so, and the bundle rarely changes mid-session
local gem_paths_cache = {}

local function gem_paths(root, callback)
  if gem_paths_cache[root] then
    return callback(gem_paths_cache[root])
  end
  if vim.fn.filereadable(root .. '/Gemfile') == 0 then
    return callback({})
  end
  vim.system({ 'bundle', 'list', '--paths' }, { cwd = root, text = true }, function(out)
    local paths = {}
    if out.code == 0 then
      for p in out.stdout:gmatch('[^\n]+') do
        table.insert(paths, p)
      end
      gem_paths_cache[root] = paths
    end
    vim.schedule(function()
      callback(paths)
    end)
  end)
end

-- Walk up from the def to name its class/module, e.g. ActiveSupport::TimeWithZone
local function owner_of(lines, lnum)
  local def_indent = #lines[lnum]:match('^%s*')
  local names = {}
  for i = lnum - 1, 1, -1 do
    local indent, kind, name = lines[i]:match('^(%s*)(%a+)%s+([%w_:]+)')
    if (kind == 'class' or kind == 'module') and #indent < def_indent then
      table.insert(names, 1, name)
      def_indent = #indent
      if def_indent == 0 then
        break
      end
    end
  end
  return #names > 0 and table.concat(names, '::') or 'Object'
end

-- The contiguous comment block above the def, then the method body up to its `end`
local function doc_snippet(lines, lnum)
  local first = lnum
  while first > 1 and lines[first - 1]:match('^%s*#') do
    first = first - 1
  end
  local indent = lines[lnum]:match('^%s*')
  local last = lnum
  -- one-liners (`def x; end`, endless `def x = y`) have no body to walk
  local sig = lines[lnum]:gsub('%b()', '', 1)
  local one_liner = sig:match('%f[%w]end%s*$') or sig:match('^%s*def%s+[%w_.]+[?!]?%s*=[^=]')
  if not one_liner then
    for i = lnum + 1, math.min(#lines, lnum + 60) do
      last = i
      if lines[i]:match('^' .. indent .. 'end%f[%W]') then
        break
      end
    end
  end
  local out = {}
  for i = first, last do
    table.insert(out, (lines[i]:gsub('^' .. indent, '', 1)))
  end
  return out
end

local function short_path(path, root)
  if vim.startswith(path, root .. '/') then
    return path:sub(#root + 2)
  end
  -- .../gems/activesupport-8.1.4.1/lib/... -> activesupport-8.1.4.1/lib/...
  return path:match('.*/gems/(.+)$') or path
end

local function show_picker(name, matches, root)
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local previewers = require('telescope.previewers')
  local conf = require('telescope.config').values

  pickers
    .new({}, {
      prompt_title = 'def ' .. name,
      finder = finders.new_table({
        results = matches,
        entry_maker = function(m)
          local label = m.owner .. (m.singleton and '.' or '#') .. name
          return {
            value = m,
            display = string.format('%-45s %s:%d', label, short_path(m.path, root), m.lnum),
            ordinal = label .. ' ' .. m.path,
            filename = m.path,
            lnum = m.lnum,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = 'Docs',
        define_preview = function(self, entry)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, entry.value.snippet)
          vim.bo[self.state.bufnr].filetype = 'ruby'
        end,
      }),
    })
    :find()
end

-- Every `def <name>` in the project and bundled gems, project code first
local function find_defs(name, root, callback)
  gem_paths(root, function(gems)
    local pattern = [[^\s*def\s+(self\.)?]] .. vim.pesc(name):gsub('%%', '\\') .. [[(\s|\(|;|$)]]
    -- every migration defines `change`, and gems' own specs are never what you're reading about
    local cmd = { 'rg', '--line-number', '--no-heading', '--with-filename', '-g', '*.rb', '-g', '!**/db/*migrate/**', '-e', pattern, root }
    if #gems > 0 then
      vim.list_extend(cmd, { '-g', '!**/gems/*/spec/**', '-g', '!**/gems/*/test/**' })
      vim.list_extend(cmd, gems)
    end

    vim.system(cmd, { text = true }, function(out)
      vim.schedule(function()
        local by_file = {}
        for path, lnum in out.stdout:gmatch('([^\n]-):(%d+):[^\n]*') do
          by_file[path] = by_file[path] or {}
          table.insert(by_file[path], tonumber(lnum))
        end

        local matches = {}
        for path, lnums in pairs(by_file) do
          local ok, lines = pcall(vim.fn.readfile, path)
          if ok then
            for _, lnum in ipairs(lnums) do
              table.insert(matches, {
                path = path,
                lnum = lnum,
                owner = owner_of(lines, lnum),
                singleton = lines[lnum]:match('def%s+self%.') ~= nil,
                snippet = doc_snippet(lines, lnum),
                in_project = vim.startswith(path, root .. '/'),
              })
            end
          end
        end

        table.sort(matches, function(a, b)
          if a.in_project ~= b.in_project then
            return a.in_project
          end
          return a.owner < b.owner
        end)
        callback(matches)
      end)
    end)
  end)
end

function M.lookup()
  local name = method_under_cursor()
  if not name then
    return vim.notify('No method under cursor', vim.log.levels.WARN)
  end
  local root = project_root(0)
  find_defs(name, root, function(matches)
    if #matches == 0 then
      return vim.notify('No `def ' .. name .. '` in project or bundle', vim.log.levels.WARN)
    end
    show_picker(name, matches, root)
  end)
end

-- Enclosing method via treesitter, else a window of lines around the cursor
local function surrounding_code(bufnr, row)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
  while ok and node do
    if node:type() == 'method' or node:type() == 'singleton_method' then
      local s, _, e = node:range()
      if e - s <= 120 then
        return vim.api.nvim_buf_get_lines(bufnr, s, e + 1, false)
      end
      break
    end
    node = node:parent()
  end
  local s = math.max(0, row - 30)
  return vim.api.nvim_buf_get_lines(bufnr, s, row + 30, false)
end

-- One reused sidebar, so answers sit next to the code instead of on top of it
local panel_buf

local function show_panel(lines)
  if not (panel_buf and vim.api.nvim_buf_is_valid(panel_buf)) then
    panel_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[panel_buf].filetype = 'markdown'
    vim.bo[panel_buf].bufhidden = 'hide'
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = panel_buf, desc = 'Close explain panel' })
  end

  vim.bo[panel_buf].modifiable = true
  vim.api.nvim_buf_set_lines(panel_buf, 0, -1, false, lines)
  vim.bo[panel_buf].modifiable = false

  local win = vim.fn.bufwinid(panel_buf)
  if win == -1 then
    -- win = -1 splits the whole editor, so the panel is full height even from a split
    win = vim.api.nvim_open_win(panel_buf, false, {
      split = 'right',
      win = -1,
      width = math.max(50, math.floor(vim.o.columns * 0.35)),
    })
    vim.wo[win].wrap = true
    vim.wo[win].linebreak = true
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = 'no'
    vim.wo[win].conceallevel = 2
    vim.wo[win].winfixwidth = true
  end
  vim.api.nvim_win_set_cursor(win, { 1, 0 })
end

function M.explain(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local target, question

  if opts.visual then
    local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
    target = table.concat(vim.fn.getregion(s, e, { type = vim.fn.visualmode() }), '\n')
    question = 'Explain what this expression does here.'
  else
    target = method_under_cursor()
    if not target then
      return vim.notify('No method under cursor', vim.log.levels.WARN)
    end
    question = string.format(
      'Explain `%s` as used on this line. Say what object the receiver is, where `%s` is defined '
        .. '(Ruby core, stdlib, or which gem/class), and what it does in this specific call.',
      target,
      target
    )
  end

  local root = project_root(bufnr)
  local context = {
    'You are explaining Ruby/Rails code to an experienced developer reading it in their editor.',
    'Answer in under 150 words of markdown. No preamble. Include a one-line example if it helps.',
    '',
    -- relative to root, which is the chat session's cwd
    'File: ' .. short_path(vim.api.nvim_buf_get_name(bufnr), root),
    'Line ' .. (row + 1) .. ': ' .. vim.trim(vim.api.nvim_get_current_line()),
    '',
    'Surrounding code:',
    '```ruby',
    table.concat(surrounding_code(bufnr, row), '\n'),
    '```',
    '',
  }

  local function ask(candidates)
    local prompt = vim.deepcopy(context)
    if opts.visual then
      vim.list_extend(prompt, { 'Selected:', '```ruby', target, '```', '' })
    end
    if candidates and #candidates > 0 then
      -- Real defs from the bundle keep it from inventing an owner (it once guessed DateAndTime::Calculations)
      table.insert(prompt, 'Every `def ' .. target .. '` in this project and its gems - the answer is one of these:')
      for i, m in ipairs(candidates) do
        if i > 60 then
          break
        end
        table.insert(prompt, '- ' .. m.owner .. (m.singleton and '.' or '#') .. target .. ' (' .. short_path(m.path, root) .. ')')
      end
      table.insert(prompt, 'If none fit the receiver, it is Ruby core (implemented in C).')
      table.insert(prompt, '')
    end
    if opts.chat then
      -- Full interactive session (default model, normal tools) so follow-ups can read the gem source.
      -- Context rides in the system prompt so the chat opens on just the question
      return vim.system({
        'tmux', 'split-window', '-h', '-l', '40%', '-c', root,
        'claude', '--append-system-prompt', table.concat(prompt, '\n'),
        question .. ' (line ' .. (row + 1) .. ' of ' .. short_path(vim.api.nvim_buf_get_name(bufnr), root) .. ')',
      },
        {},
        function(out)
          if out.code ~= 0 then
            vim.schedule(function()
              vim.notify('tmux split failed: ' .. out.stderr, vim.log.levels.ERROR)
            end)
          end
        end
      )
    end

    table.insert(prompt, question)

    -- No tools or MCP keeps startup cheap; the answer comes from the code given plus model knowledge
    vim.system(
      { 'claude', '-p', '--model', 'haiku', '--no-session-persistence', '--tools', '', '--strict-mcp-config' },
      { stdin = table.concat(prompt, '\n'), text = true, cwd = root },
      function(out)
        vim.schedule(function()
          if out.code ~= 0 then
            return show_panel({ '**claude failed**', '', out.stderr ~= '' and out.stderr or out.stdout })
          end
          show_panel(vim.split(vim.trim(out.stdout), '\n'))
        end)
      end
    )
  end

  if opts.chat and not vim.env.TMUX then
    return vim.notify('Not inside tmux', vim.log.levels.WARN)
  end
  if not opts.chat then
    show_panel({ '_Asking Claude about `' .. target:sub(1, 40) .. '`..._' })
  end
  if opts.visual then
    ask(nil)
  else
    find_defs(target, root, ask)
  end
end

return M

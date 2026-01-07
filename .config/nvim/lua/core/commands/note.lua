-- Open today's daily note file
-- This mirrors the behavior of the `note` shell script at ~/bin/note
-- If you change the logic here, update the shell script as well (and vice versa)

vim.api.nvim_create_user_command('Note', function()
  local note_dir = os.getenv('NOTE_DIR')
  if not note_dir then
    vim.notify('NOTE_DIR environment variable not set', vim.log.levels.ERROR)
    return
  end

  local today = os.date('%Y-%m-%d')
  local note_path = note_dir .. '/' .. today .. '.md'

  -- Create directory if it doesn't exist
  vim.fn.mkdir(note_dir, 'p')

  -- Create file with date header if it doesn't exist
  if vim.fn.filereadable(note_path) == 0 then
    local file = io.open(note_path, 'w')
    if file then
      file:write('# ' .. today .. '\n\n\n')
      file:close()
    end
  end

  -- Open the file, jump to end, and enter insert mode
  vim.cmd('edit ' .. vim.fn.fnameescape(note_path))
  vim.cmd('normal! G')
  vim.cmd('startinsert')
end, {})

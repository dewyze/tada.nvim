local M = {}

function M.temp_dir()
  local temp_dir = vim.fn.tempname()
  vim.fn.mkdir(temp_dir, "p")
  return temp_dir
end

function M.cleanup(path)
  if path then
    vim.fn.delete(path, "rf")
  end
end

-- Open a fresh tada buffer holding the given lines, cursor on the first
function M.plan(lines)
  vim.cmd("enew!")
  vim.bo.buftype = "nofile"
  vim.bo.filetype = "tada"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

-- Put the cursor on a line, at its first column
function M.go_to(row)
  vim.api.nvim_win_set_cursor(0, { row, 0 })
end

-- Type keys as a user would, mappings included
function M.press(keys)
  local codes = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(codes, "mx", false)
end

function M.lines()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

function M.line()
  return vim.api.nvim_get_current_line()
end

-- What the window shows: a closed fold appears as its one line of fold text
function M.shown()
  local shown, row = {}, 1

  while row <= vim.fn.line("$") do
    if vim.fn.foldclosed(row) == -1 then
      table.insert(shown, vim.fn.getline(row))
      row = row + 1
    else
      table.insert(shown, vim.fn.foldtextresult(row))
      row = vim.fn.foldclosedend(row) + 1
    end
  end

  return shown
end

-- The name of the highlight on a word in a line, or on the line's first character
function M.highlight(row, word)
  local line = vim.fn.getline(row)
  local col = word and line:find(word, 1, true) or vim.fn.indent(row) + 1

  return vim.fn.synIDattr(vim.fn.synID(row, col, 1), "name")
end

-- The colour, or the linked group, a highlight is painted with
function M.colour(group)
  local highlight = vim.api.nvim_get_hl(0, { name = group })

  return highlight.link or (highlight.fg and string.format("#%06x", highlight.fg))
end

-- The text from the cursor to the end of the line
function M.after_cursor()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return M.line():sub(col + 1)
end

return M

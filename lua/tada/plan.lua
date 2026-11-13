-- One tada file, open in a buffer. Entries are read from the buffer's text
-- each time they are asked for, so there is no second copy to fall out of step.
local kinds = require("tada.kinds")

local Plan = {}
Plan.__index = Plan

function Plan.current()
  return setmetatable({ buffer = vim.api.nvim_get_current_buf() }, Plan)
end

function Plan:under_cursor()
  return self:entry_at(vim.api.nvim_win_get_cursor(0)[1])
end

function Plan:entry_at(row)
  local line = vim.api.nvim_buf_get_lines(self.buffer, row - 1, row, false)[1]

  for _, kind in ipairs(kinds) do
    local entry = kind.read(line)

    if entry then
      entry.plan = self
      entry.row = row
      return entry
    end
  end
end

function Plan:rewrite(row, line)
  vim.api.nvim_buf_set_lines(self.buffer, row - 1, row, false, { line })
end

return Plan

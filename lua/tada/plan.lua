-- One tada file, open in a buffer. Entries are read from the buffer's text
-- each time they are asked for, so there is no second copy to fall out of step.
local kinds = require("tada.kinds")
local Outline = require("tada.outline")

local Plan = {}
Plan.__index = Plan

function Plan.current()
  return setmetatable({ buffer = vim.api.nvim_get_current_buf() }, Plan)
end

function Plan:under_cursor()
  return self:entry_at(vim.api.nvim_win_get_cursor(0)[1])
end

function Plan:entry_at(row)
  -- Above the first line and below the last, a plan is blank
  local line = row > 0 and vim.api.nvim_buf_get_lines(self.buffer, row - 1, row, false)[1] or ""

  for _, kind in ipairs(kinds) do
    local entry = kind.read(line)

    if entry then
      entry.plan = self
      entry.row = row
      return entry
    end
  end
end

-- The nearest topic below a row that is no deeper than the given depth
function Plan:topic_after(row, depth)
  return self:topic_between(row + 1, self:last_row(), depth)
end

function Plan:topic_before(row, depth)
  return self:topic_between(row - 1, 1, depth)
end

-- The folder that paths in this plan are written from: the one holding
-- .tada/, or else the plan's own
function Plan:root()
  local beside = vim.fs.dirname(vim.api.nvim_buf_get_name(self.buffer))
  local planbook = vim.fs.find(".tada", { path = beside, upward = true, type = "directory" })[1]

  return planbook and vim.fs.dirname(planbook) or beside
end

function Plan:last_row()
  return vim.api.nvim_buf_line_count(self.buffer)
end

-- Close every topic below the given level
function Plan:show_topics_to(level)
  vim.wo.foldlevel = level - 1
  vim.cmd("normal! zX")
end

function Plan:show_everything()
  vim.wo.foldlevel = Outline.levels
  vim.cmd("normal! zX")
end

function Plan:rewrite(row, line)
  vim.api.nvim_buf_set_lines(self.buffer, row - 1, row, false, { line })
end

function Plan:insert(row, line)
  vim.api.nvim_buf_set_lines(self.buffer, row - 1, row - 1, false, { line })
end

-- private

function Plan:topic_between(from, to, depth)
  for row = from, to, from <= to and 1 or -1 do
    local entry = self:entry_at(row)

    if entry:is_topic_within(depth) then
      return entry
    end
  end
end

return Plan

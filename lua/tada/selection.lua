-- A run of lines in a plan
local Selection = {}
Selection.__index = Selection

function Selection.new(plan, first, last)
  return setmetatable({ plan = plan, first = first, last = last }, Selection)
end

-- Move the lines to the plan's twin in the archive. They go in before they
-- come out, so a failed write loses nothing.
function Selection:archive()
  self.plan:archived_twin():adopt(self:with_topics_above())
  self:cut()
  self.plan:save()
end

-- private

-- The lines, headed by the titles of the topics they sit in
function Selection:with_topics_above()
  local lines = {}

  for _, topic in ipairs(self.plan:entry_at(self.first):ancestors()) do
    table.insert(lines, topic:render())
  end

  return vim.list_extend(lines, self.plan:lines(self.first, self.last))
end

function Selection:cut()
  self.plan:remove(self.first, self.last)
  vim.api.nvim_win_set_cursor(0, { math.min(self.first, self.plan:last_row()), 0 })
end

return Selection

-- One tada file. Entries are read from its buffer's text each time they are
-- asked for, so there is no second copy to fall out of step.
local kinds = require("tada.kinds")
local Outline = require("tada.outline")

local Plan = {}

-- A plan found on disk only opens its buffer when something asks for it
Plan.__index = function(plan, key)
  if key == "buffer" then
    local buffer = vim.fn.bufadd(plan.path)
    vim.fn.bufload(buffer)
    rawset(plan, "buffer", buffer)
    return buffer
  end

  return Plan[key]
end

function Plan.current()
  local buffer = vim.api.nvim_get_current_buf()

  return setmetatable({ buffer = buffer, path = vim.api.nvim_buf_get_name(buffer) }, Plan)
end

function Plan.at(path)
  return setmetatable({ path = path }, Plan)
end

-- The plans in a folder, the one edited last first
function Plan.all_in(directory)
  local plans = vim.tbl_map(Plan.at, vim.fn.glob(directory .. "/*.tada", false, true))

  return Plan.latest_first(plans)
end

function Plan.latest_first(plans)
  table.sort(plans, function(a, b)
    return a:edited_at() > b:edited_at()
  end)

  return plans
end

-- The kind of entry a line of text is
function Plan.read(line)
  for _, kind in ipairs(kinds) do
    local entry = kind.read(line)

    if entry then
      return entry
    end
  end
end

function Plan:name()
  return vim.fn.fnamemodify(self.path, ":t:r")
end

function Plan:exists()
  return vim.uv.fs_stat(self.path) ~= nil
end

function Plan:edited_at()
  local stat = vim.uv.fs_stat(self.path)

  return stat and stat.mtime.sec + stat.mtime.nsec / 1e9 or 0
end

-- The folder that paths in this plan are written from: the one holding
-- .tada/, or else the plan's own
function Plan:root()
  local beside = self.path ~= "" and vim.fs.dirname(self.path) or vim.fn.getcwd()
  local directory = vim.fs.find(".tada", { path = beside, upward = true, type = "directory" })[1]

  return directory and vim.fs.dirname(directory) or beside
end

function Plan:planbook()
  return require("tada.planbook").at(self:root())
end

-- The plan of the same name in the archive, where this plan's finished work goes
function Plan:archived_twin()
  return self:planbook():archive():plan_named(self:name())
end

-- Collect the names on this plan's assignee lines, as it stands in its buffer
function Plan:add_assignees_to(names)
  for row = 1, self:last_row() do
    self:entry_at(row):add_names_to(names)
  end
end

-- The same from the file on disk, without opening a buffer for it
function Plan:add_saved_assignees_to(names)
  for _, line in ipairs(self:exists() and vim.fn.readfile(self.path) or {}) do
    Plan.read(line):add_names_to(names)
  end
end

function Plan:under_cursor()
  return self:entry_at(vim.api.nvim_win_get_cursor(0)[1])
end

function Plan:entry_at(row)
  -- Above the first line and below the last, a plan is blank
  local line = row > 0 and vim.api.nvim_buf_get_lines(self.buffer, row - 1, row, false)[1] or ""
  local entry = Plan.read(line)

  entry.plan = self
  entry.row = row

  return entry
end

function Plan:selection(first, last)
  return require("tada.selection").new(self, first, last)
end

-- The lines selected in visual mode
function Plan:selected()
  local from, to = vim.fn.line("v"), vim.fn.line(".")

  return self:selection(math.min(from, to), math.max(from, to))
end

-- Move everything to the archive, and remove this plan
function Plan:archive()
  self:archived_twin():adopt(self:lines(1, self:last_row()))
  self:discard()
end

-- Take lines in. Where they open with topics this plan already has, the rest
-- goes under those topics; otherwise the lines go at the end.
function Plan:adopt(lines)
  local from, to, taken = 1, self:last_row(), 0

  while lines[taken + 1] do
    local topic = self:topic_like(Plan.read(lines[taken + 1]), from, to)

    if not topic then
      break
    end

    from, to, taken = topic.row + 1, topic:last_row(), taken + 1
  end

  self:insert_after(to, vim.list_slice(lines, taken + 1))
  self:save()
end

-- The nearest topic below a row that is no deeper than the given depth
function Plan:topic_after(row, depth)
  return self:topic_between(row + 1, self:last_row(), depth)
end

function Plan:topic_before(row, depth)
  return self:topic_between(row - 1, 1, depth)
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

function Plan:lines(first, last)
  return vim.api.nvim_buf_get_lines(self.buffer, first - 1, last, false)
end

function Plan:rewrite(row, line)
  vim.api.nvim_buf_set_lines(self.buffer, row - 1, row, false, { line })
end

function Plan:insert(row, line)
  vim.api.nvim_buf_set_lines(self.buffer, row - 1, row - 1, false, { line })
end

function Plan:remove(first, last)
  vim.api.nvim_buf_set_lines(self.buffer, first - 1, last, false, {})
end

function Plan:save()
  vim.fn.mkdir(vim.fs.dirname(self.path), "p")

  vim.api.nvim_buf_call(self.buffer, function()
    vim.cmd("silent write!")
  end)
end

-- private

function Plan:is_empty()
  return self:last_row() == 1 and self:lines(1, 1)[1] == ""
end

function Plan:insert_after(row, lines)
  -- A buffer with nothing in it still has one empty line; write over it
  local from = self:is_empty() and 0 or row

  vim.api.nvim_buf_set_lines(self.buffer, from, row, false, lines)
end

function Plan:discard()
  vim.fn.delete(self.path)
  vim.api.nvim_buf_delete(self.buffer, { force = true })
end

function Plan:topic_like(entry, from, to)
  for row = from, to do
    local candidate = self:entry_at(row)

    if candidate:is_same_topic_as(entry) then
      return candidate
    end
  end
end

function Plan:topic_between(from, to, depth)
  for row = from, to, from <= to and 1 or -1 do
    local entry = self:entry_at(row)

    if entry:is_topic_within(depth) then
      return entry
    end
  end
end

return Plan

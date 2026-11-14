-- What every kind of entry in a plan shares: an indent, a place in the plan,
-- and the ability to become another kind. A kind answers the keys it cares
-- about and inherits the plain behaviour for the rest: nothing happens, or
-- the key types itself.
local Outline = require("tada.outline")

local Entry = {}
Entry.__index = Entry

-- A new kind, inheriting from Entry or from a kind that already extends it
function Entry.extend(base)
  local kind = setmetatable({}, { __index = base or Entry })
  kind.__index = kind
  return kind
end

function Entry:toggle_box() end

function Entry:cycle_status() end

function Entry:start_topic()
  self:type(":")
end

function Entry:start_note()
  self:type(">")
end

function Entry:start_metadata()
  self:type("|")
end

function Entry:indent_more()
  self:type("<Tab>")
end

function Entry:indent_less()
  self:type("<S-Tab>")
end

-- Enter while typing: the words after the cursor move to a new entry below
function Entry:continue()
  local kept, carried = self:split_at_cursor()
  local successor = self:successor()

  self.plan:rewrite(self.row, kept)
  self.plan:insert(self.row + 1, successor:prefix() .. carried)
  self:put_cursor(self.row + 1, #successor:prefix())
end

function Entry:open_below()
  self.plan:insert(self.row + 1, self:successor():prefix())
  self:type_at_end_of(self.row + 1)
end

function Entry:open_above()
  self.plan:insert(self.row, self:predecessor():prefix())
  self:type_at_end_of(self.row)
end

-- Blank out everything left of the cursor, so the text continues the entry above
function Entry:clear_marker()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local blanks = string.rep(" ", vim.fn.strdisplaywidth(line:sub(1, col)))

  self.plan:rewrite(self.row, blanks .. line:sub(col + 1))
  self:put_cursor(self.row, #blanks)
end

-- ( and ): the topics at this level or above it
function Entry:previous_topic()
  self:go_to(self.plan:topic_before(self.row, self:topic_depth()))
end

function Entry:next_topic()
  self:go_to(self.plan:topic_after(self.row, self:topic_depth()))
end

-- { and }: the topics one level up
function Entry:previous_parent_topic()
  self:go_to(self.plan:topic_before(self.row, self:parent_depth()))
end

function Entry:next_parent_topic()
  self:go_to(self.plan:topic_after(self.row, self:parent_depth()))
end

-- gf: only a link has somewhere to go
function Entry:follow_link()
  self:type("gf")
end

-- Enter in normal mode: only a topic folds
function Entry:toggle_fold()
  self:type("<CR>")
end

-- How many topics deep this entry sits, as far as topics nest
function Entry:fold_level()
  return math.min(self:depth(), Outline.levels)
end

-- What a closed fold starting here shows
function Entry:summary()
  return self:render()
end

function Entry:depth()
  return #self.indent / #Outline.step
end

-- The depth of the topic this entry sits in
function Entry:topic_depth()
  return math.max(self:depth() - 1, 0)
end

function Entry:is_topic_within(_)
  return false
end

-- Whether this entry sits outside a topic that started above it
function Entry:closes(topic)
  return #self.indent <= #topic.indent
end

function Entry:add_to(tally) end

-- The entry Enter and o leave below this one
function Entry:successor()
  return require("tada.blank").new(self.indent)
end

-- The entry O leaves above this one
function Entry:predecessor()
  return self:successor()
end

-- The entry that notes and metadata here belong to
function Entry:owner()
  return self
end

function Entry:above()
  return self.plan:entry_at(self.row - 1)
end

-- The marker in front of the text, indent included
function Entry:prefix()
  return self.indent
end

function Entry:render()
  return self:prefix() .. (self.text or "")
end

function Entry:become(other)
  self.plan:rewrite(self.row, other:render())
  self:keep_cursor_on_text(other)
end

-- private

function Entry:parent_depth()
  return math.max(self:topic_depth() - 1, 0)
end

function Entry:go_to(topic)
  if topic then
    self:put_cursor(topic.row, #topic:prefix())
  end
end

function Entry:type(keys)
  local codes = vim.api.nvim_replace_termcodes(keys, true, false, true)

  -- "n" skips our own mappings; "i" puts the keys ahead of anything already typed
  vim.api.nvim_feedkeys(codes, "ni", false)
end

function Entry:type_at_end_of(row)
  self:put_cursor(row, 0)
  vim.cmd("startinsert!")
end

function Entry:put_cursor(row, col)
  vim.api.nvim_win_set_cursor(0, { row, col })
end

function Entry:split_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = math.max(vim.api.nvim_win_get_cursor(0)[2], #self:prefix())

  return (line:sub(1, col):gsub("%s+$", "")), (line:sub(col + 1):gsub("^%s+", ""))
end

function Entry:keep_cursor_on_text(other)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local was, now = #self:prefix(), #other:prefix()

  if col >= was then
    col = col + now - was
  else
    col = math.min(col, now)
  end

  self:put_cursor(row, col)
end

return Entry

local Entry = require("tada.entry")
local Outline = require("tada.outline")
local Statuses = require("tada.statuses")
local Tally = require("tada.tally")

local Topic = Entry.extend()

function Topic.new(indent, title)
  return setmetatable({ indent = indent, title = title, text = title .. ":" }, Topic)
end

-- Topics only nest so deep. A title indented further is not a topic.
function Topic.read(line)
  local indent, title = line:match("^(%s*)%-%s+(.+):$")

  return indent and #indent / #Outline.step < Outline.levels and Topic.new(indent, title)
end

function Topic:prefix()
  return self.indent .. "- "
end

function Topic:toggle_box()
  self:become(require("tada.todo").new(self.indent, Statuses.configured():first(), self.text))
end

-- Enter and o start an item inside the topic; O starts one beside it
function Topic:successor()
  return require("tada.placeholder").bulleted(self.indent .. Outline.step)
end

function Topic:predecessor()
  return require("tada.placeholder").bulleted(self.indent)
end

function Topic:topic_depth()
  return self:depth()
end

function Topic:is_topic_within(depth)
  return self:depth() <= depth
end

function Topic:toggle_fold()
  vim.cmd("normal! za")
end

-- A topic starts a fold one level deeper than the topic it sits in
function Topic:fold_level()
  return ">" .. self:depth() + 1
end

function Topic:summary()
  return self.indent .. vim.trim("❯ " .. self.text .. " " .. self:tally():to_s())
end

-- Every todo beneath this topic, nested topics included, counted by status
function Topic:tally()
  local tally = Tally.new()

  for _, entry in ipairs(self:entries()) do
    entry:add_to(tally)
  end

  return tally
end

-- Everything beneath this topic, down to the next entry that sits outside it
function Topic:entries()
  local entries = {}

  for row = self.row + 1, self.plan:last_row() do
    local entry = self.plan:entry_at(row)

    if entry:closes(self) then
      break
    end

    table.insert(entries, entry)
  end

  return entries
end

return Topic

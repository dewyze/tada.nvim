local Entry = require("tada.entry")
local Statuses = require("tada.statuses")

local Topic = Entry.extend()

function Topic.new(indent, title)
  return setmetatable({ indent = indent, title = title, text = title .. ":" }, Topic)
end

function Topic.read(line)
  local indent, title = line:match("^(%s*)%-%s+(.+):$")

  return indent and Topic.new(indent, title)
end

function Topic:prefix()
  return self.indent .. "- "
end

function Topic:toggle_box()
  self:become(require("tada.todo").new(self.indent, Statuses.configured():first(), self.text))
end

-- Enter and o start an item inside the topic; O starts one beside it
function Topic:successor()
  return require("tada.placeholder").bulleted(self.indent .. "  ")
end

function Topic:predecessor()
  return require("tada.placeholder").bulleted(self.indent)
end

return Topic

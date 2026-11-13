local Entry = require("tada.entry")
local Statuses = require("tada.statuses")

local ListItem = Entry.extend()

function ListItem.new(indent, text)
  return setmetatable({ indent = indent, text = text }, ListItem)
end

function ListItem.read(line)
  local indent, text = line:match("^(%s*)%-%s+(.+)$")

  return indent and ListItem.new(indent, text)
end

function ListItem:prefix()
  return self.indent .. "- "
end

function ListItem:toggle_box()
  self:become(require("tada.todo").new(self.indent, Statuses.configured():first(), self.text))
end

return ListItem

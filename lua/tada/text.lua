-- Words with no marker in front of them
local Entry = require("tada.entry")
local Statuses = require("tada.statuses")

local Text = Entry.extend()

function Text.new(indent, text)
  return setmetatable({ indent = indent, text = text }, Text)
end

function Text.read(line)
  local indent, text = line:match("^(%s*)(.+)$")

  return indent and Text.new(indent, text)
end

function Text:toggle_box()
  self:become(require("tada.todo").new(self.indent, Statuses.configured():first(), self.text))
end

function Text:fold_level()
  return "="
end

return Text

local Entry = require("tada.entry")

local Comment = Entry.extend()

function Comment.new(indent, text)
  return setmetatable({ indent = indent, text = text }, Comment)
end

function Comment.read(line)
  local indent, text = line:match("^(%s*)(#.*)$")

  return indent and Comment.new(indent, text)
end

return Comment

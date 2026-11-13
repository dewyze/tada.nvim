local Entry = require("tada.entry")

local Note = Entry.extend()

function Note.new(indent, text)
  return setmetatable({ indent = indent, text = text }, Note)
end

function Note.read(line)
  local indent, text = line:match("^(%s*)(>.*)$")

  return indent and Note.new(indent, text)
end

return Note

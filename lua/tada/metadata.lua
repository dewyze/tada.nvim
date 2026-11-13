local Entry = require("tada.entry")

local Metadata = Entry.extend()

function Metadata.new(indent, text)
  return setmetatable({ indent = indent, text = text }, Metadata)
end

function Metadata.read(line)
  local indent, text = line:match("^(%s*)(|.*)$")

  return indent and Metadata.new(indent, text)
end

return Metadata

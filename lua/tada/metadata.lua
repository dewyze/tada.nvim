local Entry = require("tada.entry")

local Metadata = Entry.extend()

function Metadata.new(indent, text)
  return setmetatable({ indent = indent, text = text }, Metadata)
end

function Metadata.read(line)
  local indent, text = line:match("^(%s*)|%s*(.+)$")

  return indent and Metadata.new(indent, text)
end

function Metadata:prefix()
  return self.indent .. "| "
end

function Metadata:successor()
  return require("tada.placeholder").for_metadata(self.indent)
end

function Metadata:owner()
  return self:above():owner()
end

function Metadata:fold_level()
  return "="
end

return Metadata

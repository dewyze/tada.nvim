local Entry = require("tada.entry")

local Note = Entry.extend()

function Note.new(indent, text)
  return setmetatable({ indent = indent, text = text }, Note)
end

function Note.read(line)
  local indent, text = line:match("^(%s*)>%s*(.+)$")

  return indent and Note.new(indent, text)
end

function Note:prefix()
  return self.indent .. "> "
end

function Note:successor()
  return require("tada.placeholder").for_note(self.indent)
end

function Note:owner()
  return self:above():owner()
end

return Note

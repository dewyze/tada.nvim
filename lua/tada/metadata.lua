-- A fact about the topic above it: a sigil that says which fact, and its value
local Entry = require("tada.entry")

local Metadata = Entry.extend()

Metadata.sigils = {
  ["@"] = "assignees",
  ["^"] = "start_date",
  ["$"] = "end_date",
  ["&"] = "link",
  ["#"] = "tags",
  ["!"] = "priority",
}

function Metadata.new(indent, sigil, value)
  local metadata = { indent = indent, sigil = sigil, value = value, text = sigil .. ":" .. value }
  metadata.name = Metadata.sigils[sigil]

  return setmetatable(metadata, Metadata)
end

function Metadata.read(line)
  local indent, sigil, value = line:match("^(%s*)|%s*(.):(.*)$")

  return Metadata.sigils[sigil] and Metadata.new(indent, sigil, value)
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

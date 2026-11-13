-- A bullet or a box with nothing typed after it yet
local Entry = require("tada.entry")
local Statuses = require("tada.statuses")

local Placeholder = Entry.extend()

function Placeholder.bulleted(indent)
  return setmetatable({ indent = indent, marker = "- " }, Placeholder)
end

function Placeholder.boxed(indent, status)
  status = status or Statuses.configured():first()

  return setmetatable({ indent = indent, marker = "- " .. status:box() .. " ", status = status }, Placeholder)
end

function Placeholder.read(line)
  local indent = line:match("^(%s*)%-%s*$")
  if indent then
    return Placeholder.bulleted(indent)
  end

  local symbol
  indent, symbol = line:match("^(%s*)%-%s*%[(.-)%]%s*$")
  local status = symbol and Statuses.configured():with_symbol(symbol)

  return status and Placeholder.boxed(indent, status)
end

function Placeholder:prefix()
  return self.indent .. self.marker
end

function Placeholder:toggle_box()
  if self.status then
    self:become(Placeholder.bulleted(self.indent))
  else
    self:become(Placeholder.boxed(self.indent))
  end
end

return Placeholder

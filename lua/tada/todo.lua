local Entry = require("tada.entry")
local Statuses = require("tada.statuses")

local Todo = Entry.extend()

function Todo.new(indent, status, text)
  return setmetatable({ indent = indent, status = status, text = text }, Todo)
end

function Todo.read(line)
  local indent, symbol, text = line:match("^(%s*)%-%s*%[(.-)%]%s+(.+)$")
  local status = symbol and Statuses.configured():with_symbol(symbol)

  return status and Todo.new(indent, status, text)
end

function Todo:prefix()
  return self.indent .. "- " .. self.status:box() .. " "
end

function Todo:toggle_box()
  self:become(require("tada.list_item").new(self.indent, self.text))
end

function Todo:cycle_status()
  self:become(Todo.new(self.indent, self.status:next(), self.text))
end

function Todo:successor()
  return require("tada.placeholder").boxed(self.indent)
end

return Todo

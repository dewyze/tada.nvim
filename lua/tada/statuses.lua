-- The ordered statuses a todo moves through. The first is where a todo starts.
local config = require("tada.config")

local Status = {}
Status.__index = Status

function Status:box()
  return "[" .. self.symbol .. "]"
end

function Status:next()
  return self.statuses:after(self)
end

local Statuses = {}
Statuses.__index = Statuses

local styles = {
  unicode = {
    { name = "blank", symbol = " " },
    { name = "in_progress", symbol = "•" },
    { name = "done", symbol = "✔" },
    { name = "flagged", symbol = "⚑" },
  },
  ascii = {
    { name = "blank", symbol = " " },
    { name = "in_progress", symbol = "-" },
    { name = "done", symbol = "x" },
    { name = "flagged", symbol = "o" },
  },
  simple = {
    { name = "blank", symbol = " " },
    { name = "done", symbol = "✔" },
  },
  markdown = {
    { name = "blank", symbol = " " },
    { name = "done", symbol = "x" },
  },
}

function Statuses.new(definitions)
  local statuses = setmetatable({ list = {} }, Statuses)

  for position, definition in ipairs(definitions) do
    local status = setmetatable(vim.deepcopy(definition), Status)
    status.statuses = statuses
    status.position = position
    statuses.list[position] = status
  end

  return statuses
end

function Statuses.configured()
  local options = config.options

  return Statuses.new(options.statuses or styles[options.style or "unicode"])
end

function Statuses:first()
  return self.list[1]
end

function Statuses:after(status)
  return self.list[status.position % #self.list + 1]
end

function Statuses:with_symbol(symbol)
  for _, status in ipairs(self.list) do
    if status.symbol == symbol then
      return status
    end
  end
end

return Statuses

-- A marker with nothing typed after it yet: an empty bullet, box, note or
-- metadata line. This is where Tab indents and where : > | choose what the
-- line will be; every other kind lets those keys type themselves.
local Entry = require("tada.entry")
local Statuses = require("tada.statuses")

local Placeholder = Entry.extend()

local step = require("tada.outline").step

local function new(indent, marker, fields)
  local placeholder = vim.tbl_extend("force", { indent = indent, marker = marker }, fields or {})

  return setmetatable(placeholder, Placeholder)
end

function Placeholder.bulleted(indent)
  return new(indent, "- ")
end

function Placeholder.boxed(indent, status)
  status = status or Statuses.configured():first()

  return new(indent, "- " .. status:box() .. " ", { status = status })
end

-- Notes and metadata hang under the text of the entry they belong to
function Placeholder.for_note(indent)
  return new(indent, "> ", { hangs = true })
end

function Placeholder.for_metadata(indent)
  return new(indent, "| ", { hangs = true })
end

function Placeholder.read(line)
  local indent, mark, symbol = line:match("^(%s*)([->|])%s*$")

  if mark == "-" then
    return Placeholder.bulleted(indent)
  elseif mark == ">" then
    return Placeholder.for_note(indent)
  elseif mark == "|" then
    return Placeholder.for_metadata(indent)
  end

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
    self:become(Placeholder.boxed(self:item_indent()))
  end
end

function Placeholder:start_topic()
  self:become(Placeholder.bulleted(self:item_indent():sub(#step + 1)))
end

function Placeholder:start_note()
  self:become(Placeholder.for_note(self:hanging_indent()))
end

function Placeholder:start_metadata()
  self:become(Placeholder.for_metadata(self:hanging_indent()))
end

function Placeholder:indent_more()
  self:become(self:at(self.indent .. step))
end

function Placeholder:indent_less()
  self:become(self:at(self.indent:sub(#step + 1)))
end

-- Enter on an empty marker ends the list
function Placeholder:continue()
  self.plan:rewrite(self.row, "")
  self:put_cursor(self.row, 0)
end

function Placeholder:successor()
  return self
end

function Placeholder:owner()
  return self:above():owner()
end

-- private

-- The same marker at another indent
function Placeholder:at(indent)
  return new(indent, self.marker, { status = self.status, hangs = self.hangs })
end

-- Where an item beside the owner would sit
function Placeholder:item_indent()
  if self.hangs then
    return self:owner():successor().indent
  end

  return self.indent
end

-- Where a note or metadata under the owner's text would sit
function Placeholder:hanging_indent()
  if self.hangs then
    return self.indent
  end

  return string.rep(" ", vim.fn.strdisplaywidth(self:owner():prefix()))
end

return Placeholder

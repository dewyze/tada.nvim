-- A line with nothing on it but, perhaps, its indent
local Entry = require("tada.entry")

local Blank = Entry.extend()

function Blank.new(indent)
  return setmetatable({ indent = indent }, Blank)
end

function Blank.read(line)
  local indent = line:match("^(%s*)$")

  return indent and Blank.new(indent)
end

function Blank:toggle_box()
  self:become(require("tada.placeholder").boxed(self.indent))
end

function Blank:fold_level()
  return "="
end

function Blank:closes()
  return false
end

function Blank:is_blank()
  return true
end

return Blank

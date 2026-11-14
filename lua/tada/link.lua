-- Metadata that points somewhere: a web address, or a file and perhaps a line
local Entry = require("tada.entry")
local Metadata = require("tada.metadata")
local Pane = require("tada.pane")

local Link = Entry.extend(Metadata)

function Link.read(line)
  local metadata = Metadata.read(line)

  return metadata and metadata.sigil == "&" and setmetatable(metadata, Link)
end

function Link:follow_link()
  if self.value:match("^%a[%w+.-]*://") then
    vim.ui.open(self.value)
  else
    self:open_file()
  end
end

-- private

function Link:open_file()
  local path, line = self.value:match("^(.-):(%d+)$")

  Pane.step_out()
  vim.cmd.edit(vim.fs.joinpath(self.plan:root(), path or self.value))
  self:put_cursor(tonumber(line) or 1, 0)
end

return Link

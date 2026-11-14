-- The colour of each kind of entry. A colour is a hex string, or the name
-- of a highlight group to follow.
local config = require("tada.config")
local Statuses = require("tada.statuses")

local Palette = {}
Palette.__index = Palette

local defaults = {
  topic = { "#b294bb", "#648cb4", "#de935f" },
  note = "#bfbc91",
  metadata = "#4bb1a7",
  comment = "#969896",
  too_deep = "Error",
  todo = {
    in_progress = "#f0c674",
    done = "#84b97c",
    flagged = "#cc6666",
  },
}

function Palette.configured()
  return setmetatable(vim.tbl_deep_extend("force", defaults, config.options.colors or {}), Palette)
end

function Palette:paint()
  self:colour("tadaNote", self.note)
  self:colour("tadaMetadata", self.metadata)
  self:colour("tadaComment", self.comment)
  self:colour("tadaTooDeep", self.too_deep)

  for level, colour in ipairs(self.topic) do
    self:colour("tadaTopic" .. level, colour)
  end

  for _, status in Statuses.configured():each() do
    self:colour(status:highlight(), self.todo[status.name] or status.color)
  end
end

-- private

function Palette:colour(group, colour)
  if not colour then
    return
  end

  vim.api.nvim_set_hl(0, group, colour:match("^#") and { fg = colour } or { link = colour })
end

return Palette

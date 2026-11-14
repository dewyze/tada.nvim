-- How many todos sit in each status
local Statuses = require("tada.statuses")

local Tally = {}
Tally.__index = Tally

function Tally.new()
  return setmetatable({ counts = {} }, Tally)
end

function Tally:count(status)
  self.counts[status.name] = (self.counts[status.name] or 0) + 1
end

-- "2[ ], 1[✔]": statuses in their order, leaving out the ones with no todos
function Tally:to_s()
  local parts = {}

  for _, status in Statuses.configured():each() do
    local count = self.counts[status.name]

    if count then
      table.insert(parts, count .. status:box())
    end
  end

  return table.concat(parts, ", ")
end

return Tally

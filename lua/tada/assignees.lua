-- Metadata naming who a topic belongs to: | @:alice,bob
local config = require("tada.config")
local Entry = require("tada.entry")
local Metadata = require("tada.metadata")

local Assignees = Entry.extend(Metadata)

function Assignees.read(line)
  local metadata = Metadata.read(line)

  return metadata and metadata.sigil == "@" and setmetatable(metadata, Assignees)
end

function Assignees:names()
  return vim.tbl_map(vim.trim, vim.split(self.value, ",", { trimempty = true }))
end

function Assignees:add_names_to(names)
  for _, name in ipairs(self:names()) do
    names[name] = true
  end
end

-- While typing a name, offer the known ones that start the same way
function Assignees:suggest()
  local typed, starts_at = self:name_being_typed()
  local matches = vim.tbl_filter(function(name)
    return vim.startswith(name, typed) and name ~= typed
  end, self:known_names())

  if #matches > 0 then
    vim.fn.complete(starts_at, matches)
  end
end

-- private

-- Every name on other assignee lines, here and in the plans beside this one,
-- plus any listed in setup(). Names already on this line are left out.
function Assignees:known_names()
  local names = self.plan:planbook():assignees()

  self.plan:add_assignees_to(names)

  for _, name in ipairs(config.options.assignees or {}) do
    names[name] = true
  end

  for _, name in ipairs(self:names()) do
    names[name] = nil
  end

  local known = vim.tbl_keys(names)
  table.sort(known)

  return known
end

-- The text between the last comma or colon and the cursor, and its column
function Assignees:name_being_typed()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local typed = vim.api.nvim_get_current_line():sub(1, col):match("[^,:]*$"):gsub("^%s+", "")

  return typed, col - #typed + 1
end

return Assignees

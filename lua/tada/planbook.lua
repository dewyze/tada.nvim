-- The .tada/ folder of a project: its plans, and the archive of finished ones
local Plan = require("tada.plan")

local Planbook = {}
Planbook.__index = Planbook

function Planbook.at(root)
  return setmetatable({ root = root }, Planbook)
end

-- The planbook of the project being worked in
function Planbook.here()
  local directory = vim.fs.find(".tada", { path = vim.fn.getcwd(), upward = true, type = "directory" })[1]

  return Planbook.at(directory and vim.fs.dirname(directory) or vim.fn.getcwd())
end

function Planbook:directory()
  return vim.fs.joinpath(self.root, ".tada")
end

-- Every live plan, the one edited last first. A Tadafile beside .tada/ counts.
function Planbook:plans()
  local plans = Plan.all_in(self:directory())
  local tadafile = Plan.at(vim.fs.joinpath(self.root, "Tadafile"))

  if tadafile:exists() then
    table.insert(plans, tadafile)
  end

  return Plan.latest_first(plans)
end

function Planbook:latest_plan()
  return self:plans()[1]
end

function Planbook:plan_named(name)
  return Plan.at(vim.fs.joinpath(self:directory(), name .. ".tada"))
end

-- Every name assigned anywhere in the live plans, as a set
function Planbook:assignees()
  local names = {}

  for _, plan in ipairs(self:plans()) do
    plan:add_saved_assignees_to(names)
  end

  return names
end

function Planbook:archive()
  return require("tada.archive").of(self)
end

return Planbook

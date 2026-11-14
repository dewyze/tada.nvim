-- Where finished work goes: .tada/archive/, one file per plan it came from
local Plan = require("tada.plan")

local Archive = {}
Archive.__index = Archive

function Archive.of(planbook)
  return setmetatable({ directory = vim.fs.joinpath(planbook:directory(), "archive") }, Archive)
end

function Archive:plans()
  return Plan.all_in(self.directory)
end

function Archive:plan_named(name)
  return Plan.at(vim.fs.joinpath(self.directory, name .. ".tada"))
end

return Archive

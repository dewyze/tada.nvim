-- Where Neovim's fold options reach the plan: 'foldexpr' and 'foldtext'
-- can only call a function by name, so these two pass the question on.
local Plan = require("tada.plan")

local M = {}

function M.level()
  return Plan.current():entry_at(vim.v.lnum):fold_level()
end

function M.text()
  return Plan.current():entry_at(vim.v.foldstart):summary()
end

return M

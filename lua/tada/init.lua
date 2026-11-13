local config = require("tada.config")

local M = {}

function M.setup(options)
  config.options = options or {}
end

return M

if vim.b.current_syntax then
  return
end

local Outline = require("tada.outline")
local Palette = require("tada.palette")
local Statuses = require("tada.statuses")

local function match(group, pattern)
  vim.cmd("syntax match " .. group .. " /" .. pattern .. "/")
end

-- A title is a bullet that ends in a colon and does not start with a box
local title = [[-\s\+\zs\%(\[.\{-}\]\s\)\@!.\+\ze:$]]

match("tadaComment", [[^\s*#.*$]])
match("tadaNote", [[^\s*>.*$]])
match("tadaMetadata", [[^\s*|\s*[@^$&#!]:.*$]])

for level = 1, Outline.levels do
  match("tadaTopic" .. level, [[^\s\{]] .. (level - 1) * #Outline.step .. "}" .. title)
end

match("tadaTooDeep", [[^\s\{]] .. Outline.levels * #Outline.step .. [[,}]] .. title)

for _, status in Statuses.configured():each() do
  match(status:highlight(), [[^\s*-\s*\[\V]] .. vim.fn.escape(status.symbol, [[\/]]) .. [[\m\]\%(\s.*\)\?$]])
end

Palette.configured():paint()

-- A colorscheme clears every highlight when it loads, so paint again after it
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("tada_palette", { clear = true }),
  callback = function()
    Palette.configured():paint()
  end,
})

vim.b.current_syntax = "tada"

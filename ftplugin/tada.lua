local Plan = require("tada.plan")

vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true
vim.bo.commentstring = "# %s"

-- Each key asks the entry under the cursor to do one thing
local function map(modes, key, action, desc)
  vim.keymap.set(modes, key, function()
    local entry = Plan.current():under_cursor()
    entry[action](entry)
  end, { buffer = true, desc = desc })
end

map({ "n", "i" }, "<C-Space>", "toggle_box", "Add or remove a todo box")
map("n", "<Space>", "cycle_status", "Move a todo to its next status")

map("i", "<CR>", "continue", "Carry on with the same kind of entry")
map("n", "o", "open_below", "Start an entry below")
map("n", "O", "open_above", "Start an entry above")

map("i", "<Tab>", "indent_more", "Indent an empty entry")
map("i", "<S-Tab>", "indent_less", "Outdent an empty entry")
map("i", ":", "start_topic", "Step an empty entry out, ready for a topic")
map("i", ">", "start_note", "Turn an empty entry into a note")
map("i", "|", "start_metadata", "Turn an empty entry into metadata")
map("i", "<C-H>", "clear_marker", "Blank out everything left of the cursor")

vim.wo[0][0].foldmethod = "expr"
vim.wo[0][0].foldexpr = "v:lua.require'tada.folds'.level()"
vim.wo[0][0].foldtext = "v:lua.require'tada.folds'.text()"
vim.wo[0][0].foldlevel = 3
vim.wo[0][0].fillchars = "fold: "

local prefix = "<C-T>"

map("n", "<CR>", "toggle_fold", "Open or close a topic")
vim.keymap.set("n", prefix .. "o", "zO", { buffer = true, desc = "Open the topics around the cursor" })
vim.keymap.set("n", prefix .. "c", "zc", { buffer = true, desc = "Close the topic around the cursor" })

for depth = 0, 3 do
  vim.keymap.set("n", prefix .. depth, function()
    Plan.current():show_topics_to(depth)
  end, { buffer = true, desc = depth == 0 and "Show everything" or "Show topics down to level " .. depth })
end

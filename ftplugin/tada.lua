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

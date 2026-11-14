local Keys = require("tada.keys")
local Outline = require("tada.outline")
local Plan = require("tada.plan")

vim.bo.shiftwidth = #Outline.step
vim.bo.tabstop = #Outline.step
vim.bo.softtabstop = #Outline.step
vim.bo.expandtab = true
vim.bo.commentstring = "# %s"

vim.wo[0][0].foldmethod = "expr"
vim.wo[0][0].foldexpr = "v:lua.require'tada.folds'.level()"
vim.wo[0][0].foldtext = "v:lua.require'tada.folds'.text()"
vim.wo[0][0].foldlevel = Outline.levels
vim.wo[0][0].fillchars = "fold: "

local keys = Keys.configured()

local function map(modes, key, desc, action)
  if key then
    vim.keymap.set(modes, key, action, { buffer = true, desc = desc })
  end
end

-- Each of these keys asks the entry under the cursor to do one thing
local function ask(modes, action, desc)
  map(modes, keys[action], desc, function()
    local entry = Plan.current():under_cursor()
    entry[action](entry)
  end)
end

ask({ "n", "i" }, "toggle_box", "Add or remove a todo box")
ask("n", "cycle_status", "Move a todo to its next status")

ask("i", "continue", "Carry on with the same kind of entry")
ask("n", "open_below", "Start an entry below")
ask("n", "open_above", "Start an entry above")

ask("i", "indent_more", "Indent an empty entry")
ask("i", "indent_less", "Outdent an empty entry")
ask("i", "start_topic", "Step an empty entry out, ready for a topic")
ask("i", "start_note", "Turn an empty entry into a note")
ask("i", "start_metadata", "Turn an empty entry into metadata")
ask("i", "clear_marker", "Blank out everything left of the cursor")

ask("n", "toggle_fold", "Open or close a topic")

ask("n", "previous_topic", "Go to the topic before")
ask("n", "next_topic", "Go to the next topic")
ask("n", "previous_parent_topic", "Go to the topic one level up")
ask("n", "next_parent_topic", "Go to the next topic one level up")
ask("n", "follow_link", "Open what a link points to")

local function under_prefix(key)
  return keys.prefix and keys.prefix .. key
end

map("n", under_prefix("o"), "Open the topics around the cursor", "zO")
map("n", under_prefix("c"), "Close the topic around the cursor", "zc")
map("n", under_prefix("0"), "Show everything", function()
  Plan.current():show_everything()
end)

for level = 1, Outline.levels do
  map("n", under_prefix(level), "Show topics down to level " .. level, function()
    Plan.current():show_topics_to(level)
  end)
end

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

-- While a completion menu is open with a name chosen, these keys belong to it
local in_menu = { continue = "<C-Y>", indent_more = "<C-N>", indent_less = "<C-P>" }

local function menu_key(action)
  local menu = vim.fn.complete_info({ "pum_visible", "selected" })
  local choosing = action ~= "continue" or menu.selected ~= -1

  return menu.pum_visible == 1 and choosing and in_menu[action]
end

-- Each of these keys asks the entry under the cursor to do one thing
local function ask(modes, action, desc)
  map(modes, keys[action], desc, function()
    local key = menu_key(action)

    if key then
      return vim.api.nvim_feedkeys(vim.keycode(key), "ni", false)
    end

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
  return keys.prefix and key and keys.prefix .. key
end

map("n", under_prefix(keys.archive), "Archive this entry and everything under it", function()
  Plan.current():under_cursor():archive()
end)
map("x", under_prefix(keys.archive), "Archive the lines selected", function()
  local selection = Plan.current():selected()
  vim.cmd.normal({ vim.keycode("<Esc>"), bang = true })
  selection:archive()
end)
map("n", under_prefix(keys.archive_plan), "Archive the whole plan", function()
  require("tada").archive_plan()
end)

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

-- A plan started from the picker has no folder until it is first written
vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = 0,
  callback = function(event)
    vim.fn.mkdir(vim.fs.dirname(event.match), "p")
  end,
})

-- Offer names while typing assignees, without choosing one until asked
pcall(function()
  vim.bo.completeopt = "menuone,noselect"
end)

vim.api.nvim_create_autocmd("TextChangedI", {
  buffer = 0,
  callback = function()
    Plan.current():under_cursor():suggest()
  end,
})

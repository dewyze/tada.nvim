-- The key each action is on. setup({ keys = { ... } }) moves an action to
-- another key, or turns it off with false.
local config = require("tada.config")

local Keys = {}

local defaults = {
  toggle_box = "<C-Space>",
  cycle_status = "<Space>",
  clear_marker = "<C-H>",
  prefix = "<C-T>",

  continue = "<CR>",
  open_below = "o",
  open_above = "O",
  indent_more = "<Tab>",
  indent_less = "<S-Tab>",
  start_topic = ":",
  start_note = ">",
  start_metadata = "|",
  toggle_fold = "<CR>",

  previous_topic = "(",
  next_topic = ")",
  previous_parent_topic = "{",
  next_parent_topic = "}",
  follow_link = "gf",
}

function Keys.configured()
  return vim.tbl_extend("force", defaults, config.options.keys or {})
end

return Keys

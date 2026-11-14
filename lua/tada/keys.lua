-- The key each action is on. setup({ keys = { ... } }) moves an action to
-- another key, gives it several with a list, or turns it off with false.
local config = require("tada.config")

local Keys = {}

local defaults = {
  toggle_box = "<C-Space>",
  cycle_status = "<Space>",
  clear_marker = "<C-H>",

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

  -- The one key that works everywhere, not only in a plan
  pane = "<LocalLeader>td",

  -- No key until given one. Vim's own zM, zR, zm, zr, zO and zc fold a plan,
  -- and :Tada has a subcommand for each of the rest.
  levels = false, -- the key before a level: "<C-q>" gives <C-q>1 to <C-q>3, and <C-q>0 to show everything
  open_topic = false,
  close_topic = false,
  archive_entry = false,
  archive_selection = false, -- in visual mode
  archive_plan = false,
  archived = false,
  pick = false, -- works everywhere, like pane
}

function Keys.configured()
  return vim.tbl_extend("force", defaults, config.options.keys or {})
end

return Keys

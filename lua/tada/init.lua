local config = require("tada.config")
local Keys = require("tada.keys")
local Pane = require("tada.pane")
local Planbook = require("tada.planbook")

local M = {}

local start_a_plan = "New plan…"

function M.setup(options)
  config.options = options or {}
  M.map_keys()
end

-- Open the plan edited last in the pane, or close the pane if it is open
function M.pane()
  if Pane.is_open() then
    return Pane.close()
  end

  local plan = Planbook.here():latest_plan()

  if plan then
    Pane.show(plan)
  else
    M.start_plan()
  end
end

-- Choose a plan to show, or start one
function M.pick()
  local choices = Planbook.here():plans()
  table.insert(choices, start_a_plan)

  M.choose("Plans", choices, function(choice)
    if choice == start_a_plan then
      M.start_plan()
    else
      Pane.show(choice)
    end
  end)
end

-- Choose an archived plan to show
function M.archived()
  M.choose("Archived plans", Planbook.here():archive():plans(), Pane.show)
end

function M.start_plan()
  vim.ui.input({ prompt = "Name for the plan: " }, function(name)
    if name and name ~= "" then
      Pane.show(Planbook.here():plan_named(name))
    end
  end)
end

-- The keys that work everywhere, not only in a plan
function M.map_keys()
  for _, key in ipairs(M.mapped or {}) do
    pcall(vim.keymap.del, "n", key)
  end

  M.mapped = {}

  local keys = Keys.configured()
  local actions = {
    pane = "Open or close the plan pane",
    pick = "Pick a plan",
    archived = "Pick an archived plan",
  }

  for action, desc in pairs(actions) do
    if keys[action] then
      vim.keymap.set("n", keys[action], M[action], { desc = desc })
      table.insert(M.mapped, keys[action])
    end
  end
end

-- private

function M.choose(prompt, choices, on_choice)
  local function label(choice)
    return type(choice) == "string" and choice or choice:name()
  end

  vim.ui.select(choices, { prompt = prompt, format_item = label }, function(choice)
    if choice then
      on_choice(choice)
    end
  end)
end

return M

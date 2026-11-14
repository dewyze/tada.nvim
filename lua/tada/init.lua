local config = require("tada.config")
local Keys = require("tada.keys")
local Pane = require("tada.pane")
local Plan = require("tada.plan")
local Planbook = require("tada.planbook")

local M = {}

local start_a_plan = "New plan…"

function M.setup(options)
  config.options = options or {}
  M.map_keys()
  M.define_command()
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

-- Start a plan with the name given, or ask for one
function M.start_plan(name)
  if name then
    return Pane.show(Planbook.here():plan_named(name))
  end

  vim.ui.input({ prompt = "Name for the plan: " }, function(answer)
    if answer and answer ~= "" then
      M.start_plan(answer)
    end
  end)
end

-- Archive the lines from first to last, or the entry under the cursor and everything beneath it
function M.archive(first, last)
  local plan = Plan.current()

  if first then
    plan:selection(first, last):archive()
  else
    plan:under_cursor():archive()
  end
end

-- Archive the whole plan and remove it, after asking
function M.archive_plan()
  local plan = Plan.current()
  local question = "Archive all of " .. plan:name() .. " and remove the plan?"

  M.choose(question, { "Archive", "Cancel" }, function(answer)
    if answer == "Archive" then
      plan:archive()
    end
  end)
end

local subcommands = {
  pane = function()
    M.pane()
  end,
  pick = function()
    M.pick()
  end,
  archived = function()
    M.archived()
  end,
  new = function(command)
    M.start_plan(command.fargs[2])
  end,
  archive = function(command)
    if command.range > 0 then
      M.archive(command.line1, command.line2)
    else
      M.archive()
    end
  end,
  ["archive-plan"] = function()
    M.archive_plan()
  end,
}

-- :Tada, with a subcommand for each thing the keys can do outside of editing
function M.define_command()
  vim.api.nvim_create_user_command("Tada", function(command)
    local subcommand = subcommands[command.fargs[1] or "pane"]

    if subcommand then
      subcommand(command)
    else
      vim.notify("Tada has no command " .. command.fargs[1], vim.log.levels.ERROR)
    end
  end, {
    nargs = "*",
    range = true,
    desc = "Open the plan pane, or run a Tada subcommand",
    complete = function(typed)
      local names = vim.tbl_keys(subcommands)
      table.sort(names)

      return vim.tbl_filter(function(name)
        return vim.startswith(name, typed)
      end, names)
    end,
  })
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

-- The side window a plan is shown in
local config = require("tada.config")

local Pane = {}

local splits = {
  right = "botright vertical new",
  left = "topleft vertical new",
  top = "topleft new",
  bottom = "botright new",
}

local function window()
  for _, candidate in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.w[candidate].tada_pane then
      return candidate
    end
  end
end

local function options()
  return vim.tbl_extend("force", { side = "right" }, config.options.pane or {})
end

-- A third of the screen, and no wider than 60 columns
local function size(side)
  local chosen = options().size

  if type(chosen) == "function" then
    return chosen()
  elseif chosen then
    return chosen
  elseif side == "left" or side == "right" then
    return math.min(math.floor(vim.o.columns * 0.33 + 0.5), 60)
  else
    return math.floor(vim.o.lines * 0.33 + 0.5)
  end
end

local function open()
  local side = options().side
  local vertical = side == "left" or side == "right"

  vim.cmd(splits[side])
  vim.bo.bufhidden = "wipe"
  vim.w.tada_pane = true
  vim.wo.winfixwidth = vertical
  vim.wo.winfixheight = not vertical

  if vertical then
    vim.api.nvim_win_set_width(0, size(side))
  else
    vim.api.nvim_win_set_height(0, size(side))
  end

  return vim.api.nvim_get_current_win()
end

function Pane.show(plan)
  vim.api.nvim_set_current_win(window() or open())
  vim.cmd.edit(vim.fn.fnameescape(plan.path))
end

function Pane.is_open()
  return window() ~= nil
end

function Pane.close()
  pcall(vim.api.nvim_win_close, window(), false)
end

-- Leave the pane for the window worked in before it, if the cursor is in the pane
function Pane.step_out()
  if vim.w.tada_pane and #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.cmd.wincmd("p")
  end
end

return Pane

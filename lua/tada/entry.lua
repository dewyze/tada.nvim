-- What every kind of entry in a plan shares: an indent, a place in the plan,
-- and the ability to become another kind. A kind answers the keys it cares
-- about and inherits "nothing happens" for the rest.
local Entry = {}
Entry.__index = Entry

function Entry.extend()
  local kind = setmetatable({}, { __index = Entry })
  kind.__index = kind
  return kind
end

function Entry:toggle_box() end

function Entry:cycle_status() end

-- The marker in front of the text, indent included
function Entry:prefix()
  return self.indent
end

function Entry:render()
  return self:prefix() .. (self.text or "")
end

function Entry:become(other)
  self.plan:rewrite(self.row, other:render())
  self:keep_cursor_on_text(other)
end

-- private

function Entry:keep_cursor_on_text(other)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local was, now = #self:prefix(), #other:prefix()

  if col >= was then
    col = col + now - was
  else
    col = math.min(col, now)
  end

  vim.api.nvim_win_set_cursor(0, { row, col })
end

return Entry

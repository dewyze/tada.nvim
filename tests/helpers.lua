local M = {}

function M.temp_dir()
  local temp_dir = vim.fn.tempname()
  vim.fn.mkdir(temp_dir, "p")
  return temp_dir
end

function M.cleanup(path)
  if path then
    vim.fn.delete(path, "rf")
  end
end

return M

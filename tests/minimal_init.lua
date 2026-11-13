-- Minimal Neovim init for testing: this plugin and plenary, nothing else

local root = vim.fn.getcwd()

-- Use the plenary lazy.nvim already installed, or clone one into .deps/
local plenary = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
if not vim.uv.fs_stat(plenary) then
  plenary = root .. "/.deps/plenary.nvim"
  if not vim.uv.fs_stat(plenary) then
    vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/nvim-lua/plenary.nvim", plenary })
  end
end

vim.opt.rtp:prepend(plenary)
vim.opt.rtp:prepend(root)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.swapfile = false

local Plan = require("tada.plan")

vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true
vim.bo.commentstring = "# %s"

vim.keymap.set({ "n", "i" }, "<C-Space>", function()
  Plan.current():under_cursor():toggle_box()
end, { buffer = true, desc = "Add or remove a todo box" })

vim.keymap.set("n", "<Space>", function()
  Plan.current():under_cursor():cycle_status()
end, { buffer = true, desc = "Move a todo to its next status" })

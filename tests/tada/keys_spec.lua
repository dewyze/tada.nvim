local assert = require("luassert")
local helpers = require("tests.helpers")

describe("keys", function()
  it("can be moved to another key", function()
    require("tada").setup({ keys = { toggle_box = "<C-B>" } })
    helpers.plan({ "- milk" })

    helpers.press("<C-B>")

    assert.equals("- [ ] milk", helpers.line())
  end)

  it("leave the old key alone once moved", function()
    require("tada").setup({ keys = { cycle_status = "<C-N>" } })
    helpers.plan({ "- [ ] milk" })

    helpers.press("<Space>")

    assert.equals("- [ ] milk", helpers.line())
  end)

  it("can be turned off", function()
    require("tada").setup({ keys = { start_topic = false } })
    helpers.plan({ "  - " })

    helpers.press("A:")

    assert.equals("  - :", helpers.line())
  end)

  it("can put the fold levels after a key", function()
    require("tada").setup({ keys = { levels = "<Leader>t" } })
    helpers.plan({ "- Shop:", "  - [ ] milk" })

    helpers.press("<Leader>t1")

    assert.same({ "❯ Shop: 1[ ]" }, helpers.shown())
  end)

  it("can put one action on several keys", function()
    require("tada").setup({ keys = { cycle_status = { "<Space>", "<C-N>" } } })
    helpers.plan({ "- [ ] milk" })

    helpers.press("<Space><C-N>")

    assert.equals("- [✔] milk", helpers.line())
  end)

  it("act at once, without waiting on a longer mapping of your own", function()
    require("tada").setup({})
    vim.keymap.set("n", "<CR><CR>", "i<CR><Esc>")
    helpers.plan({ "- Shop:", "  - [ ] milk" })

    assert.equals(1, vim.fn.maparg("<CR>", "n", false, true).nowait)

    vim.keymap.del("n", "<CR><CR>")
  end)

  it("claim only the pane key outside of plans by default", function()
    require("tada").setup({})

    assert.same(
      { true, false, false },
      { vim.fn.maparg("\\td", "n") ~= "", vim.fn.maparg("\\tp", "n") ~= "", vim.fn.maparg("\\ta", "n") ~= "" }
    )
  end)
end)

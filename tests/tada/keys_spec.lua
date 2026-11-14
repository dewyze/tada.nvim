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

  it("can take another prefix for the fold keys", function()
    require("tada").setup({ keys = { prefix = "<Leader>t" } })
    helpers.plan({ "- Shop:", "  - [ ] milk" })

    helpers.press("<Leader>t1")

    assert.same({ "❯ Shop: 1[ ]" }, helpers.shown())
  end)
end)

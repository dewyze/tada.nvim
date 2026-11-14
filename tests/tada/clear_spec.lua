local assert = require("luassert")
local helpers = require("tests.helpers")

describe("<C-H>", function()
  it("clears an empty bullet so text continues the entry above", function()
    helpers.plan({ "- Topic:", "  - " })
    helpers.go_to(2)

    helpers.press("A<C-H>Description")

    assert.equals("    Description", helpers.line())
  end)

  it("clears everything left of the cursor and leaves the text in place", function()
    helpers.plan({ "- [✔] Todo Item", "- [✔] Description" })
    helpers.go_to(2)

    helpers.press("fDi<C-H>")

    assert.equals("      Description", helpers.line())
  end)
end)

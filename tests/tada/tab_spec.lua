local assert = require("luassert")
local helpers = require("tests.helpers")

describe("Tab", function()
  before_each(function()
    require("tada").setup({})
  end)

  it("indents an empty item", function()
    helpers.plan({ "- [ ] " })

    helpers.press("A<Tab>milk")

    assert.equals("  - [ ] milk", helpers.line())
  end)

  it("indents an empty note", function()
    helpers.plan({ "  > " })

    helpers.press("A<Tab>why")

    assert.equals("    > why", helpers.line())
  end)

  it("outdents an empty item with Shift", function()
    helpers.plan({ "  - " })

    helpers.press("A<S-Tab>milk")

    assert.equals("- milk", helpers.line())
  end)

  it("types a tab anywhere else", function()
    helpers.plan({ "- milk" })

    helpers.press("A<Tab>x")

    assert.equals("- milk  x", helpers.line())
  end)
end)

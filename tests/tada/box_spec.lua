local assert = require("luassert")
local helpers = require("tests.helpers")

describe("<C-Space>", function()
  before_each(function()
    require("tada").setup({})
  end)

  it("puts a box on a list item", function()
    helpers.plan({ "- milk" })

    helpers.press("<C-Space>")

    assert.equals("- [ ] milk", helpers.line())
  end)

  it("takes the box off a todo", function()
    helpers.plan({ "- [✔] milk" })

    helpers.press("<C-Space>")

    assert.equals("- milk", helpers.line())
  end)

  it("keeps the indent", function()
    helpers.plan({ "    - milk" })

    helpers.press("<C-Space>")

    assert.equals("    - [ ] milk", helpers.line())
  end)

  it("puts a box on a topic", function()
    helpers.plan({ "- Shop:" })

    helpers.press("<C-Space>")

    assert.equals("- [ ] Shop:", helpers.line())
  end)

  it("gives a boxed topic its title back", function()
    helpers.plan({ "- [ ] Shop:" })

    helpers.press("<C-Space>")

    assert.equals("- Shop:", helpers.line())
  end)

  it("starts a todo on a blank line", function()
    helpers.plan({ "" })

    helpers.press("A<C-Space>milk")

    assert.equals("- [ ] milk", helpers.line())
  end)

  it("puts a box on an empty bullet", function()
    helpers.plan({ "  - " })

    helpers.press("A<C-Space>milk")

    assert.equals("  - [ ] milk", helpers.line())
  end)

  it("takes the box off an empty todo", function()
    helpers.plan({ "  - [ ] " })

    helpers.press("A<C-Space>milk")

    assert.equals("  - milk", helpers.line())
  end)

  it("turns plain text into a todo", function()
    helpers.plan({ "  milk" })

    helpers.press("<C-Space>")

    assert.equals("  - [ ] milk", helpers.line())
  end)

  it("leaves a note alone", function()
    helpers.plan({ "  > remember the milk" })

    helpers.press("<C-Space>")

    assert.equals("  > remember the milk", helpers.line())
  end)

  it("keeps the cursor on the same character when the box appears", function()
    helpers.plan({ "- milk" })
    helpers.press("fl")

    helpers.press("<C-Space>")

    assert.equals("lk", helpers.after_cursor())
  end)

  it("moves a cursor inside the box to the text when the box goes", function()
    helpers.plan({ "- [ ] milk" })
    helpers.press("f]")

    helpers.press("<C-Space>")

    assert.equals("milk", helpers.after_cursor())
  end)
end)

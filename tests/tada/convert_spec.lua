local assert = require("luassert")
local helpers = require("tests.helpers")

describe("on an empty item", function()
  before_each(function()
    require("tada").setup({})
  end)

  it("> hangs a note under the text above", function()
    helpers.plan({ "- [✔] milk", "- [ ] " })
    helpers.go_to(2)

    helpers.press("A>why")

    assert.equals("      > why", helpers.line())
  end)

  it("| hangs metadata under the topic above", function()
    helpers.plan({ "- Shop:", "  - " })
    helpers.go_to(2)

    helpers.press("A|@:alice")

    assert.equals("  | @:alice", helpers.line())
  end)

  it(": steps out a level, ready for a topic", function()
    helpers.plan({ "- Shop:", "  - [ ] milk", "  - [ ] " })
    helpers.go_to(3)

    helpers.press("A:Home:")

    assert.equals("- Home:", helpers.line())
  end)

  it("<C-Space> on an empty note starts the next todo", function()
    helpers.plan({ "- [ ] milk", "      > " })
    helpers.go_to(2)

    helpers.press("A<C-Space>eggs")

    assert.equals("- [ ] eggs", helpers.line())
  end)
end)

describe("anywhere else", function()
  it(": > and | type themselves", function()
    helpers.plan({ "- milk" })

    helpers.press("A: > |")

    assert.equals("- milk: > |", helpers.line())
  end)
end)

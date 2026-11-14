local assert = require("luassert")
local helpers = require("tests.helpers")

describe("Enter while typing", function()
  before_each(function()
    require("tada").setup({})
  end)

  it("starts a new todo after a todo", function()
    helpers.plan({ "- [✔] milk" })

    helpers.press("A<CR>eggs")

    assert.same({ "- [✔] milk", "- [ ] eggs" }, helpers.lines())
  end)

  it("starts a new list item after a list item", function()
    helpers.plan({ "  - milk" })

    helpers.press("A<CR>eggs")

    assert.same({ "  - milk", "  - eggs" }, helpers.lines())
  end)

  it("starts an item inside a topic", function()
    helpers.plan({ "- Shop:" })

    helpers.press("A<CR>milk")

    assert.same({ "- Shop:", "  - milk" }, helpers.lines())
  end)

  it("carries on a note", function()
    helpers.plan({ "      > why" })

    helpers.press("A<CR>more")

    assert.same({ "      > why", "      > more" }, helpers.lines())
  end)

  it("carries on metadata", function()
    helpers.plan({ "  | @:alice" })

    helpers.press("A<CR>!:High")

    assert.same({ "  | @:alice", "  | !:High" }, helpers.lines())
  end)

  it("ends the list on an empty item", function()
    helpers.plan({ "- [ ] milk", "- [ ] " })
    helpers.go_to(2)

    helpers.press("A<CR>")

    assert.same({ "- [ ] milk", "" }, helpers.lines())
  end)

  it("takes the words after the cursor to the new todo", function()
    helpers.plan({ "- [ ] milk and eggs" })

    helpers.press("fai<CR>")

    assert.same({ "- [ ] milk", "- [ ] and eggs" }, helpers.lines())
  end)

  it("keeps the indent of plain text", function()
    helpers.plan({ "  words" })

    helpers.press("A<CR>more")

    assert.same({ "  words", "  more" }, helpers.lines())
  end)
end)

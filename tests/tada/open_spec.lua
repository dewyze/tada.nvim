local assert = require("luassert")
local helpers = require("tests.helpers")

describe("o and O", function()
  before_each(function()
    require("tada").setup({})
  end)

  it("o starts a new todo below a todo", function()
    helpers.plan({ "- [✔] milk", "- [ ] bread" })

    helpers.press("oeggs")

    assert.same({ "- [✔] milk", "- [ ] eggs", "- [ ] bread" }, helpers.lines())
  end)

  it("O starts a new todo above a todo", function()
    helpers.plan({ "- [✔] milk" })

    helpers.press("Oeggs")

    assert.same({ "- [ ] eggs", "- [✔] milk" }, helpers.lines())
  end)

  it("o starts an item inside a topic", function()
    helpers.plan({ "- Shop:" })

    helpers.press("omilk")

    assert.same({ "- Shop:", "  - milk" }, helpers.lines())
  end)

  it("O starts an item beside a topic", function()
    helpers.plan({ "  - Shop:" })

    helpers.press("OHome:")

    assert.same({ "  - Home:", "  - Shop:" }, helpers.lines())
  end)

  it("o keeps the indent of plain text", function()
    helpers.plan({ "  words" })

    helpers.press("omore")

    assert.same({ "  words", "  more" }, helpers.lines())
  end)
end)

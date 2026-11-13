local assert = require("luassert")
local helpers = require("tests.helpers")

describe("<Space>", function()
  before_each(function()
    require("tada").setup({})
  end)

  it("moves a todo through the statuses and back to the first", function()
    helpers.plan({ "- [ ] milk" })
    local seen = {}

    for _ = 1, 4 do
      helpers.press("<Space>")
      table.insert(seen, helpers.line())
    end

    assert.same({ "- [•] milk", "- [✔] milk", "- [⚑] milk", "- [ ] milk" }, seen)
  end)

  it("leaves a list item alone", function()
    helpers.plan({ "- milk" })

    helpers.press("<Space>")

    assert.equals("- milk", helpers.line())
  end)

  it("keeps the cursor on the same character when the symbol changes width", function()
    helpers.plan({ "- [ ] milk" })
    helpers.press("fl")

    helpers.press("<Space>")

    assert.equals("lk", helpers.after_cursor())
  end)

  it("uses the symbols of the chosen style", function()
    require("tada").setup({ style = "ascii" })
    helpers.plan({ "- [ ] milk" })

    helpers.press("<Space>")

    assert.equals("- [-] milk", helpers.line())
  end)

  it("uses custom statuses in the order given", function()
    require("tada").setup({
      statuses = {
        { name = "planned", symbol = " " },
        { name = "doing", symbol = "🛠️" },
        { name = "complete", symbol = "✅" },
      },
    })
    helpers.plan({ "- [🛠️] milk" })

    helpers.press("<Space>")

    assert.equals("- [✅] milk", helpers.line())
  end)
end)

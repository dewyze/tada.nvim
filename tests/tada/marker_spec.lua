local assert = require("luassert")
local helpers = require("tests.helpers")

-- Saving often strips trailing spaces, which leaves an empty box as "- [ ]"
describe("typing on an empty marker that has lost its trailing space", function()
  before_each(function()
    require("tada").setup({})
  end)

  it("puts the space back after a box", function()
    helpers.plan({ "  - [ ]" })

    helpers.press("A" .. helpers.typed("milk"))

    assert.equals("  - [ ] milk", helpers.line())
  end)

  it("puts the space back after a bullet", function()
    helpers.plan({ "  -" })

    helpers.press("A" .. helpers.typed("milk"))

    assert.equals("  - milk", helpers.line())
  end)

  it("puts the space back after a note marker", function()
    helpers.plan({ "      >" })

    helpers.press("A" .. helpers.typed("why"))

    assert.equals("      > why", helpers.line())
  end)

  it("does not double the space when a space is typed", function()
    helpers.plan({ "  - [ ]" })

    helpers.press("A" .. helpers.typed(" milk"))

    assert.equals("  - [ ] milk", helpers.line())
  end)

  it("puts back one space, however many times the buffer became a plan", function()
    helpers.plan({ "  - [ ]" })
    vim.bo.filetype = "tada"
    vim.bo.filetype = "tada"

    helpers.press("A" .. helpers.typed("milk"))

    assert.equals("  - [ ] milk", helpers.line())
  end)

  it("leaves a line with text on it alone", function()
    helpers.plan({ "- milk" })

    helpers.press("A" .. helpers.typed("!"))

    assert.equals("- milk!", helpers.line())
  end)
end)

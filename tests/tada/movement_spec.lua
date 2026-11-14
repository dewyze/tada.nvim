local assert = require("luassert")
local helpers = require("tests.helpers")

describe("moving between topics", function()
  before_each(function()
    require("tada").setup({})
    helpers.plan({
      "- Shop:",
      "  - Food:",
      "    - [ ] milk",
      "  - Drinks:",
      "    - [ ] tea",
      "- Home:",
      "  - [ ] paint",
    })
  end)

  it(") goes from a topic to the next one beside it", function()
    helpers.go_to(2)

    helpers.press(")")

    assert.equals("Drinks:", helpers.after_cursor())
  end)

  it(") goes up a level when there is no topic left beside it", function()
    helpers.go_to(4)

    helpers.press(")")

    assert.equals("Home:", helpers.after_cursor())
  end)

  it("( goes from a topic to the one before it", function()
    helpers.go_to(4)

    helpers.press("(")

    assert.equals("Food:", helpers.after_cursor())
  end)

  it("( goes from a todo to the topic it sits in", function()
    helpers.go_to(3)

    helpers.press("(")

    assert.equals("Food:", helpers.after_cursor())
  end)

  it(") goes from a todo to the topic after the one it sits in", function()
    helpers.go_to(3)

    helpers.press(")")

    assert.equals("Drinks:", helpers.after_cursor())
  end)

  it("{ goes to the topic one level up", function()
    helpers.go_to(3)

    helpers.press("{")

    assert.equals("Shop:", helpers.after_cursor())
  end)

  it("} goes to the next topic one level up", function()
    helpers.go_to(2)

    helpers.press("}")

    assert.equals("Home:", helpers.after_cursor())
  end)

  it("stays put when there is no topic to go to", function()
    helpers.go_to(6)

    helpers.press(")")

    assert.equals(6, helpers.row())
  end)
end)

describe("gf on a link", function()
  local dir
  local open = vim.ui.open

  before_each(function()
    require("tada").setup({})
    dir = helpers.temp_dir()
    helpers.write(dir .. "/lua/thing.lua", { "one", "two", "three", "four" })
  end)

  after_each(function()
    vim.ui.open = open
    helpers.cleanup(dir)
  end)

  it("opens the file at the line, from the folder the plans belong to", function()
    helpers.write(dir .. "/.tada/plan.tada", { "- Thing:", "  | &:lua/thing.lua:3" })
    helpers.open(dir .. "/.tada/plan.tada")
    helpers.go_to(2)

    helpers.press("gf")

    assert.same({ "thing.lua", "three" }, { vim.fn.expand("%:t"), helpers.line() })
  end)

  it("opens a file with no line number at its top", function()
    helpers.write(dir .. "/.tada/plan.tada", { "- Thing:", "  | &:lua/thing.lua" })
    helpers.open(dir .. "/.tada/plan.tada")
    helpers.go_to(2)

    helpers.press("gf")

    assert.same({ "thing.lua", "one" }, { vim.fn.expand("%:t"), helpers.line() })
  end)

  it("hands a web address to the system", function()
    local opened
    vim.ui.open = function(address)
      opened = address
    end
    helpers.plan({ "| &:https://example.com/project" })

    helpers.press("gf")

    assert.equals("https://example.com/project", opened)
  end)
end)

local assert = require("luassert")
local helpers = require("tests.helpers")

describe("typing assignees", function()
  local dir

  before_each(function()
    require("tada").setup({})
    dir = helpers.workspace()
  end)

  after_each(function()
    helpers.cleanup(dir)
  end)

  local function errands()
    helpers.write(dir .. "/.tada/errands.tada", { "- Shop:", "  | @:alice,bob", "- Home:", "  | " })
    helpers.open(dir .. "/.tada/errands.tada")
    helpers.go_to(4)
  end

  it("offers the names used elsewhere in the plan", function()
    errands()

    helpers.press("A" .. helpers.typed("@:") .. "<C-N><C-Y>")

    assert.equals("  | @:alice", helpers.line())
  end)

  it("narrows to the names that start with what is typed", function()
    errands()

    helpers.press("A" .. helpers.typed("@:b") .. "<C-N><C-Y>")

    assert.equals("  | @:bob", helpers.line())
  end)

  it("offers names again after a comma, without the ones already there", function()
    errands()

    helpers.press("A" .. helpers.typed("@:alice,") .. "<C-N><C-Y>")

    assert.equals("  | @:alice,bob", helpers.line())
  end)

  it("offers names from the other plans beside this one", function()
    helpers.write(dir .. "/.tada/garden.tada", { "- Dig:", "  | @:carol" })
    errands()

    helpers.press("A" .. helpers.typed("@:c") .. "<C-N><C-Y>")

    assert.equals("  | @:carol", helpers.line())
  end)

  it("offers names listed in setup", function()
    require("tada").setup({ assignees = { "dave" } })
    errands()

    helpers.press("A" .. helpers.typed("@:d") .. "<C-N><C-Y>")

    assert.equals("  | @:dave", helpers.line())
  end)

  it("takes the chosen name on Enter, without starting a new line", function()
    errands()

    helpers.press("A" .. helpers.typed("@:") .. "<C-N><CR>")

    assert.same({ "  | @:alice", 4 }, { helpers.line(), vim.fn.line("$") })
  end)

  it("moves through the names with Tab", function()
    errands()

    helpers.press("A" .. helpers.typed("@:") .. "<Tab><Tab><C-Y>")

    assert.equals("  | @:bob", helpers.line())
  end)

  it("offers nothing on other metadata", function()
    errands()

    helpers.press("A" .. helpers.typed("!:") .. "<C-N><C-Y>")

    assert.equals("  | !:", helpers.line())
  end)
end)

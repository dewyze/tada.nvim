local assert = require("luassert")
local helpers = require("tests.helpers")

describe("folds", function()
  local shopping = {
    "- Shop:",
    "  - Food:",
    "    - [ ] milk",
    "    - [✔] eggs",
    "          > free range",
    "  - [ ] bags",
    "- Home:",
    "  - [•] paint",
  }

  before_each(function()
    require("tada").setup({ keys = { levels = "<C-T>", open_topic = { "<C-T>o", "<C-T>O" }, close_topic = "<C-T>c" } })
    helpers.plan(shopping)
  end)

  it("has no level keys until they are given, leaving Vim's own to work", function()
    require("tada").setup({})
    helpers.plan(shopping)

    helpers.press("zM")

    assert.same({ { "❯ Shop: 2[ ], 1[✔]", "❯ Home: 1[•]" }, "" }, { helpers.shown(), vim.fn.maparg("<C-T>1", "n") })
  end)

  it("<C-T>1 shows only the top topics, with their todos counted", function()
    helpers.press("<C-T>1")

    assert.same({ "❯ Shop: 2[ ], 1[✔]", "❯ Home: 1[•]" }, helpers.shown())
  end)

  it("<C-T>2 shows the second level of topics", function()
    helpers.press("<C-T>2")

    assert.same({
      "- Shop:",
      "  ❯ Food: 1[ ], 1[✔]",
      "  - [ ] bags",
      "- Home:",
      "  - [•] paint",
    }, helpers.shown())
  end)

  it("<C-T>0 shows everything", function()
    helpers.press("<C-T>1")

    helpers.press("<C-T>0")

    assert.same(shopping, helpers.shown())
  end)

  it("Enter closes the topic under the cursor", function()
    helpers.go_to(2)

    helpers.press("<CR>")

    assert.same({ "- Shop:", "  ❯ Food: 1[ ], 1[✔]", "  - [ ] bags", "- Home:", "  - [•] paint" }, helpers.shown())
  end)

  it("Enter opens a closed topic", function()
    helpers.go_to(2)
    helpers.press("<CR>")

    helpers.press("<CR>")

    assert.same(shopping, helpers.shown())
  end)

  it("Enter moves down a line anywhere else", function()
    helpers.go_to(3)

    helpers.press("<CR>")

    assert.equals("    - [✔] eggs", helpers.line())
  end)

  it("can have keys that close the topic around the cursor and open it fully", function()
    helpers.go_to(3)

    helpers.press("<C-T>c")
    local closed = helpers.shown()
    helpers.press("<C-T>O")

    assert.same("  ❯ Food: 1[ ], 1[✔]", closed[2])
    assert.same(shopping, helpers.shown())
  end)

  it("leaves a header above the first topic in view", function()
    helpers.plan({ "> Weekend errands", "| &:https://example.com/errands", "- Shop:", "  - [ ] milk" })

    helpers.press("<C-T>1")

    assert.same({ "> Weekend errands", "| &:https://example.com/errands", "❯ Shop: 1[ ]" }, helpers.shown())
  end)

  it("shows a topic with no todos by its title alone", function()
    helpers.plan({ "- Ideas:", "  - a thought" })

    helpers.press("<C-T>1")

    assert.same({ "❯ Ideas:" }, helpers.shown())
  end)
end)

describe("a topic nested four deep", function()
  before_each(function()
    require("tada").setup({ keys = { levels = "<C-T>" } })
    helpers.plan({
      "- One:",
      "  - Two:",
      "    - Three:",
      "      - Four:",
      "        - [ ] too deep",
    })
  end)

  it("does not fold", function()
    helpers.press("<C-T>0")
    helpers.go_to(4)

    helpers.press("<CR>")

    assert.equals(5, #helpers.shown())
  end)

  it("is marked as too deep", function()
    assert.equals("tadaTooDeep", helpers.highlight(4, "Four"))
  end)

  it("leaves a third-level topic unmarked", function()
    assert.is_not.equals("tadaTooDeep", helpers.highlight(3, "Three"))
  end)
end)

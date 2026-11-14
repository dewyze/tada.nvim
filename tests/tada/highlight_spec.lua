local assert = require("luassert")
local helpers = require("tests.helpers")

describe("highlighting", function()
  before_each(function()
    require("tada").setup({})
    helpers.plan({
      "> Weekend errands",
      "| &:https://example.com/errands",
      "- Shop:",
      "  - Food:",
      "    - Dairy:",
      "      - [ ] milk",
      "      - [•] butter",
      "      - [✔] eggs",
      "      - [⚑] cream",
      "      - a plain item",
      "      | not metadata",
      "# a comment",
    })
  end)

  it("gives each level of topic its own group", function()
    assert.same(
      { "tadaTopic1", "tadaTopic2", "tadaTopic3" },
      { helpers.highlight(3, "Shop"), helpers.highlight(4, "Food"), helpers.highlight(5, "Dairy") }
    )
  end)

  it("gives a todo the group of its status", function()
    assert.same(
      { "tadaTodoBlank", "tadaTodoInProgress", "tadaTodoDone", "tadaTodoFlagged" },
      { helpers.highlight(6), helpers.highlight(7), helpers.highlight(8), helpers.highlight(9) }
    )
  end)

  it("marks notes, metadata and comments", function()
    assert.same(
      { "tadaNote", "tadaMetadata", "tadaComment" },
      { helpers.highlight(1), helpers.highlight(2), helpers.highlight(12) }
    )
  end)

  it("leaves a list item plain", function()
    assert.equals("", helpers.highlight(10))
  end)

  it("leaves a line with an unknown sigil plain", function()
    assert.equals("", helpers.highlight(11))
  end)

  it("names a custom status's group after the status", function()
    require("tada").setup({ statuses = { { name = "planned", symbol = " " }, { name = "doing", symbol = "🛠️" } } })
    helpers.plan({ "- [🛠️] paint" })

    assert.equals("tadaTodoDoing", helpers.highlight(1))
  end)
end)

describe("colours", function()
  it("come with a palette", function()
    require("tada").setup({})
    helpers.plan({ "- Shop:" })

    assert.same(
      { "#b294bb", "#648cb4", "#de935f", "#bfbc91", "#84b97c" },
      {
        helpers.colour("tadaTopic1"),
        helpers.colour("tadaTopic2"),
        helpers.colour("tadaTopic3"),
        helpers.colour("tadaNote"),
        helpers.colour("tadaTodoDone"),
      }
    )
  end)

  it("can be replaced one at a time", function()
    require("tada").setup({ colors = { note = "#ff0000", todo = { done = "#00ff00" } } })
    helpers.plan({ "- Shop:" })

    assert.same(
      { "#ff0000", "#00ff00", "#cc6666" },
      { helpers.colour("tadaNote"), helpers.colour("tadaTodoDone"), helpers.colour("tadaTodoFlagged") }
    )
  end)

  it("can follow a highlight group of the colorscheme", function()
    require("tada").setup({ colors = { comment = "Comment" } })
    helpers.plan({ "- Shop:" })

    assert.equals("Comment", helpers.colour("tadaComment"))
  end)

  it("can be set on a custom status", function()
    require("tada").setup({ statuses = { { name = "planned", symbol = " " }, { name = "doing", symbol = "~", color = "#123456" } } })
    helpers.plan({ "- Shop:" })

    assert.equals("#123456", helpers.colour("tadaTodoDoing"))
  end)

  it("survive a change of colorscheme", function()
    require("tada").setup({})
    helpers.plan({ "- Shop:" })

    vim.cmd.colorscheme("habamax")

    assert.equals("#bfbc91", helpers.colour("tadaNote"))
  end)
end)

local assert = require("luassert")
local helpers = require("tests.helpers")

describe("archiving, with keys given for it", function()
  local dir, plan, archived

  before_each(function()
    require("tada").setup({
      keys = { archive_entry = "<C-T>a", archive_selection = "<C-T>a", archive_plan = "<C-T>A" },
    })
    dir = helpers.workspace()
    plan = dir .. "/.tada/errands.tada"
    archived = dir .. "/.tada/archive/errands.tada"
  end)

  after_each(function()
    helpers.restore_ui()
    helpers.cleanup(dir)
  end)

  it("moves a topic and everything under it to the plan's file in archive/", function()
    helpers.write(plan, { "- Shop:", "  - [✔] milk", "- Home:", "  - [ ] paint" })
    helpers.open(plan)

    helpers.press("<C-T>a")

    assert.same(
      { { "- Home:", "  - [ ] paint" }, { "- Shop:", "  - [✔] milk" } },
      { helpers.read(plan), helpers.read(archived) }
    )
  end)

  it("takes a todo's notes with it, under the topics it sat in", function()
    helpers.write(plan, { "- Shop:", "  - Food:", "    - [✔] milk", "          > oat", "    - [ ] eggs" })
    helpers.open(plan)
    helpers.go_to(3)

    helpers.press("<C-T>a")

    assert.same({
      { "- Shop:", "  - Food:", "    - [ ] eggs" },
      { "- Shop:", "  - Food:", "    - [✔] milk", "          > oat" },
    }, { helpers.read(plan), helpers.read(archived) })
  end)

  it("files a todo under the topics the archive already has", function()
    helpers.write(plan, { "- Shop:", "  - Food:", "    - [✔] milk" })
    helpers.write(archived, { "- Shop:", "  - Food:", "    - [✔] bread", "- Home:", "  - [✔] paint" })
    helpers.open(plan)
    helpers.go_to(3)

    helpers.press("<C-T>a")

    assert.same(
      { "- Shop:", "  - Food:", "    - [✔] bread", "    - [✔] milk", "- Home:", "  - [✔] paint" },
      helpers.read(archived)
    )
  end)

  it("joins a topic to the same topic in the archive", function()
    helpers.write(plan, { "- Shop:", "  - [✔] milk", "- Home:" })
    helpers.write(archived, { "- Shop:", "  - [✔] bread" })
    helpers.open(plan)

    helpers.press("<C-T>a")

    assert.same({ "- Shop:", "  - [✔] bread", "  - [✔] milk" }, helpers.read(archived))
  end)

  it("moves the lines selected", function()
    helpers.write(plan, { "- Shop:", "  - [✔] milk", "  - [✔] eggs", "  - [ ] tea" })
    helpers.open(plan)

    helpers.press("jVj<C-T>a")

    assert.same(
      { { "- Shop:", "  - [ ] tea" }, { "- Shop:", "  - [✔] milk", "  - [✔] eggs" } },
      { helpers.read(plan), helpers.read(archived) }
    )
  end)

  it("leaves the cursor where the lines were", function()
    helpers.write(plan, { "- Shop:", "  - [✔] milk", "  - [ ] tea" })
    helpers.open(plan)
    helpers.go_to(2)

    helpers.press("<C-T>a")

    assert.equals("  - [ ] tea", helpers.line())
  end)

  it("moves the whole plan with <C-T>A and removes it, once confirmed", function()
    helpers.write(plan, { "> Weekend", "- Shop:", "  - [✔] milk" })
    helpers.open(plan)
    helpers.choose("Archive")

    helpers.press("<C-T>A")

    assert.same(
      { false, { "> Weekend", "- Shop:", "  - [✔] milk" } },
      { helpers.exists(plan), helpers.read(archived) }
    )
  end)

  it("names the plan when it asks", function()
    helpers.write(plan, { "- Shop:" })
    helpers.open(plan)
    helpers.choose("Cancel")

    helpers.press("<C-T>A")

    assert.equals("Archive all of errands and remove the plan?", helpers.asked)
  end)

  it("leaves the plan alone when the whole-plan archive is cancelled", function()
    helpers.write(plan, { "- Shop:", "  - [✔] milk" })
    helpers.open(plan)
    helpers.choose("Cancel")

    helpers.press("<C-T>A")

    assert.same({ { "- Shop:", "  - [✔] milk" }, false }, { helpers.read(plan), helpers.exists(archived) })
  end)
end)

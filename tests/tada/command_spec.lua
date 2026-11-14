local assert = require("luassert")
local helpers = require("tests.helpers")

describe(":Tada", function()
  local dir, plan, archived

  before_each(function()
    require("tada").setup({})
    dir = helpers.workspace()
    plan = dir .. "/.tada/errands.tada"
    archived = dir .. "/.tada/archive/errands.tada"
  end)

  after_each(function()
    helpers.restore_ui()
    helpers.cleanup(dir)
  end)

  local function shown()
    return vim.fn.expand("%:t")
  end

  it("opens the plan pane", function()
    helpers.write_plan(plan, { "- Shop:" })

    vim.cmd("Tada")

    assert.same({ "errands.tada", 2 }, { shown(), vim.fn.winnr("$") })
  end)

  it("pick shows the plan picked", function()
    helpers.write_plan(plan, { "- Shop:" }, 5)
    helpers.write_plan(dir .. "/.tada/garden.tada", { "- Dig:" }, 1)
    helpers.choose("errands")

    vim.cmd("Tada pick")

    assert.equals("errands.tada", shown())
  end)

  it("archived shows the archived plan picked", function()
    helpers.write_plan(archived, { "- Shop:" })
    helpers.choose("errands")

    vim.cmd("Tada archived")

    assert.equals(archived, vim.fn.expand("%:p"))
  end)

  it("new starts a plan with the name given", function()
    vim.cmd("Tada new garden")

    assert.equals("garden.tada", shown())
  end)

  it("archive moves the entry under the cursor", function()
    helpers.write(plan, { "- Shop:", "  - [✔] milk", "- Home:" })
    helpers.open(plan)

    vim.cmd("Tada archive")

    assert.same({ { "- Home:" }, { "- Shop:", "  - [✔] milk" } }, { helpers.read(plan), helpers.read(archived) })
  end)

  it("archive with a range moves those lines", function()
    helpers.write(plan, { "- Shop:", "  - [✔] milk", "  - [✔] eggs", "  - [ ] tea" })
    helpers.open(plan)

    vim.cmd("2,3Tada archive")

    assert.same({ "- Shop:", "  - [ ] tea" }, helpers.read(plan))
  end)

  it("archive-plan moves the whole plan, once confirmed", function()
    helpers.write(plan, { "- Shop:" })
    helpers.open(plan)
    helpers.choose("Archive")

    vim.cmd("Tada archive-plan")

    assert.same({ false, { "- Shop:" } }, { helpers.exists(plan), helpers.read(archived) })
  end)

  it("completes its subcommands", function()
    assert.same({ "archive", "archive-plan", "archived" }, vim.fn.getcompletion("Tada arch", "cmdline"))
  end)
end)

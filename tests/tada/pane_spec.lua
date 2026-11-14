local assert = require("luassert")
local helpers = require("tests.helpers")

describe("the plan pane", function()
  local dir

  before_each(function()
    require("tada").setup({})
    dir = helpers.workspace()
  end)

  after_each(function()
    helpers.restore_ui()
    helpers.cleanup(dir)
  end)

  local function shown()
    return vim.fn.expand("%:t")
  end

  it("opens the plan edited last, in a pane on the right", function()
    helpers.write_plan(dir .. "/.tada/errands.tada", { "- Shop:" }, 5)
    helpers.write_plan(dir .. "/.tada/garden.tada", { "- Dig:" }, 1)

    helpers.press("\\td")

    assert.same({ "garden.tada", 2, true }, { shown(), vim.fn.winnr("$"), vim.fn.winnr() == vim.fn.winnr("$") })
  end)

  it("is a third of the screen wide, up to 60 columns", function()
    helpers.write_plan(dir .. "/.tada/errands.tada", { "- Shop:" })

    helpers.press("\\td")

    assert.equals(math.min(math.floor(vim.o.columns * 0.33 + 0.5), 60), vim.api.nvim_win_get_width(0))
  end)

  it("closes when the key is pressed again", function()
    helpers.write_plan(dir .. "/.tada/errands.tada", { "- Shop:" })
    helpers.press("\\td")

    helpers.press("\\td")

    assert.equals(1, vim.fn.winnr("$"))
  end)

  it("opens a Tadafile beside .tada/ when that is the plan there is", function()
    helpers.write_plan(dir .. "/Tadafile", { "- Shop:" })

    helpers.press("\\td")

    assert.equals("Tadafile", shown())
  end)

  it("can sit on another side at another size", function()
    require("tada").setup({ pane = { side = "left", size = 30 } })
    helpers.write_plan(dir .. "/.tada/errands.tada", { "- Shop:" })

    helpers.press("\\td")

    assert.same({ 1, 30 }, { vim.fn.winnr(), vim.api.nvim_win_get_width(0) })
  end)

  it("asks for a name and starts a plan when there are none", function()
    helpers.answer("errands")

    helpers.press("\\td")
    vim.cmd("silent write")

    assert.same({ "errands.tada", true }, { shown(), helpers.exists(dir .. "/.tada/errands.tada") })
  end)

  it("offers the plans to pick from, latest first, and shows the one picked", function()
    helpers.write_plan(dir .. "/.tada/errands.tada", { "- Shop:" }, 5)
    helpers.write_plan(dir .. "/.tada/garden.tada", { "- Dig:" }, 1)
    helpers.choose("errands")
    require("tada").setup({ keys = { pick = "\\tp" } })

    helpers.press("\\tp")

    assert.same({ "errands.tada", { "garden", "errands", "New plan…" } }, { shown(), helpers.offered })
  end)

  it("starts a plan from the picker", function()
    helpers.write_plan(dir .. "/.tada/errands.tada", { "- Shop:" })
    helpers.choose("New plan…")
    helpers.answer("garden")
    require("tada").setup({ keys = { pick = "\\tp" } })

    helpers.press("\\tp")

    assert.equals("garden.tada", shown())
  end)

  it("offers archived plans apart from the live ones, from a key given inside a plan", function()
    require("tada").setup({ keys = { archived = "\\ta" } })
    helpers.write_plan(dir .. "/.tada/errands.tada", { "- Shop:" })
    helpers.write_plan(dir .. "/.tada/archive/moving.tada", { "- Pack:" })
    helpers.choose("moving")
    helpers.press("\\td")

    helpers.press("\\ta")

    assert.same({ "moving.tada", { "moving" } }, { shown(), helpers.offered })
  end)

  it("opens a link's file in the window beside the pane", function()
    helpers.write(dir .. "/lua/thing.lua", { "one", "two" })
    helpers.write_plan(dir .. "/.tada/errands.tada", { "| &:lua/thing.lua:2" })
    helpers.press("\\td")

    helpers.press("gf")

    assert.same({ "thing.lua", 2, 1 }, { shown(), vim.fn.winnr("$"), vim.fn.winnr() })
  end)
end)

local assert = require("luassert")
local helpers = require("tests.helpers")

describe("filetype", function()
  local dir

  before_each(function()
    dir = helpers.temp_dir()
  end)

  after_each(function()
    helpers.cleanup(dir)
  end)

  it("is tada for a .tada file", function()
    vim.cmd.edit(dir .. "/plan.tada")

    assert.equals("tada", vim.bo.filetype)
  end)

  it("is tada for a Tadafile", function()
    vim.cmd.edit(dir .. "/Tadafile")

    assert.equals("tada", vim.bo.filetype)
  end)
end)

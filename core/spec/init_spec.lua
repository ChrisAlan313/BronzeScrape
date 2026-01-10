local helper = require("spec_helper")

describe("core basic", function()
  it("passes a trivial assertion", function()
    assert.is_true(true)
  end)
end)

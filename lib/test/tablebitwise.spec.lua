local tbw = require("lib/src/tablebitwise")

describe("boolean table bitwise and", function()
  it("should process two boolean lists", function()
    local t1 = {true, true, true}
    local t2 = {true, true, false}
    local expected = {true, true, false}

    -- when
    local result = tbw.tand(t1, t2)
    
    -- then
    assert.are.same(expected, result)
  end)

  it("handles lists with different lengths", function()
    --given
    local t1_left = {true, true, true, true, false}
    local t2_left = {true, true, false}
    local expected_left = {true, true, false, false, false}

    -- when
    local result_left = tbw.tand(t1_left, t2_left)
    
    -- then
    assert.are.same(expected_left, result_left)


    -- given
    local t1_right = {true, true, true}
    local t2_right = {true, true, false, true, true, false}
    local expected_right = {true, true, false, false, false, false}

    -- when
    local result_right = tbw.tand(t1_right, t2_right)
    
    -- then
    assert.are.same(expected_right, result_right)
  end)
end)


describe("boolean table bitwise or", function()
  it("should process two boolean lists", function()
    local t1 = {true, true, true}
    local t2 = {true, true, false}
    local expected = {true, true, true}

    -- when
    local result = tbw.tor(t1, t2)
    
    -- then
    assert.are.same(expected, result)
  end)

  it("handles lists with different lengths", function()
    --given
    local t1_left = {true, true, true, true, false}
    local t2_left = {true, true, false}
    local expected_left = {true, true, true, true, false}

    -- when
    local result_left = tbw.tor(t1_left, t2_left)
    
    -- then
    assert.are.same(expected_left, result_left)


    -- given
    local t1_right = {true, true, true}
    local t2_right = {true, true, false, true, true, false}
    local expected_right = {true, true, true, true, true, false}

    -- when
    local result_right = tbw.tor(t1_right, t2_right)
    
    -- then
    assert.are.same(expected_right, result_right)
  end)
end)
local helper = require("lib/src/helper")

describe("helper", function()
  it("should generate a euclidean rhythm", function()
    -- when
    local result = helper.er_gen(3,8)
    local expected = {true, false, false, true, false, false, true, false}

    assert.are.same(expected, result)
  end)

  it("should convert bpm to seconds (* 4)", function()
    local result = helper.bpm_to_sec(120)
    local expected = 0.125

    assert.is.equal(expected, result)
  end)

  it("should convert seconds (* 4) to bpm", function()
    local result = helper.sec_to_bpm(0.125)
    local expected = 120

    assert.is.equal(expected, result)
  end)

  it("converts note values to volts", function()
    local result = helper.note_to_volt(57)
    local expected = 4.75

    assert.is.equal(expected, result)
  end)

  it("should shift a table left", function()
    local result = helper.tab.shift_left({1, 2, 3, 4})
    local expected = {2, 3, 4, 1}

    assert.are.same(expected, result)
  end)

  it("should shift a table right", function()
    local result = helper.tab.shift_right({1, 2, 3, 4})
    local expected = {4, 1, 2, 3}

    assert.are.same(expected, result)
  end)

  it("should clone a table", function()
    local input_table = {1, 2, 3}
    local table_clone = helper.tab.clone(input_table)
    assert.is_not.equal(input_table, table_clone)
    assert.are.same(input_table, table_clone)
  end)
end)
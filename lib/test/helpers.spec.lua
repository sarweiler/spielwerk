local helpers = require("lib/src/helpers")

describe("helpers", function()
  it("should generate a euclidean rhythm", function()
    -- when
    local result = helpers.er_gen(3,8)
    local expected = {true, false, false, true, false, false, true, false}

    assert.are.same(expected, result)
  end)

  it("should convert bpm to seconds", function()
    local result = helpers.bpm_to_sec(120)
    local expected = 0.5

    assert.is.equal(expected, result)
  end)

  it("should convert seconds to bpm", function()
    local result = helpers.sec_to_bpm(0.5)
    local expected = 120

    assert.is.equal(expected, result)
  end)

  it("converts note values to volts", function()
    local result = helpers.note_to_volt(57)
    local expected = 4.75

    assert.is.equal(expected, result)
  end)

  it("should shift a table left", function()
    local result = helpers.tab.shift_left({1, 2, 3, 4})
    local expected = {2, 3, 4, 1}

    assert.are.same(expected, result)
  end)

  it("should shift a table right", function()
    local result = helpers.tab.shift_right({1, 2, 3, 4})
    local expected = {4, 1, 2, 3}

    assert.are.same(expected, result)
  end)

  it("should clone a table", function()
    local input_table = {1, 2, 3}
    local table_clone = helpers.tab.clone(input_table)
    assert.is_not.equal(input_table, table_clone)
    assert.are.same(input_table, table_clone)
  end)

  it("should preprocess scales in norns musicutil form", function()
    local SCALES = {
      {name = "Major", alt_names = {"Ionian"}, intervals = {0, 2, 4, 5, 7, 9, 11, 12}, chords = {{1, 2, 3, 4, 5, 6, 7, 14}, {14, 15, 17, 18, 19, 20, 21, 22, 23}, {14, 15, 17, 19}, {1, 2, 3, 4, 5}, {1, 2, 4, 8, 9, 10, 11, 14, 15}, {14, 15, 17, 19, 21, 22}, {24, 26}, {1, 2, 3, 4, 5, 6, 7, 14}}},
      {name = "Natural Minor", alt_names = {"Minor", "Aeolian"}, intervals = {0, 2, 3, 5, 7, 8, 10, 12}, chords = {{14, 15, 17, 19, 21, 22}, {24, 26}, {1, 2, 3, 4, 5, 6, 7, 14}, {14, 15, 17, 18, 19, 20, 21, 22, 23}, {14, 15, 17, 19}, {1, 2, 3, 4, 5}, {1, 2, 4, 8, 9, 10, 11, 14, 15}, {14, 15, 17, 19, 21, 22}}}
    }

    local result = helpers.preprocess_scales(SCALES)
    local expected = {
      ["major"] = {0, 2, 4, 5, 7, 9, 11, 12},
      ["natural minor"] = {0, 2, 3, 5, 7, 8, 10, 12}
    }

    assert.are.same(expected, result)
  end)

  it("should quantize a note to a scale", function()
    local scale = {0, 2, 4, 5, 7, 9, 11, 12}
    local note = 6

    local result = helpers.quantize(scale, note)
    local expected = 5

    assert.is.equal(expected, result)
  end)

  it("should not change a note that is in the scale", function()
    local scale = {0, 2, 4, 5, 7, 9, 11, 12}
    local note = 9

    local result = helpers.quantize(scale, note)
    local expected = 9

    assert.is.equal(expected, result)
  end)

  it("should quantize a note value that has a value of more than one octave", function()
    local scale = {0, 2, 4, 5, 7, 9, 11, 12}
    local note = 18

    local result = helpers.quantize(scale, note)
    local expected = 5

    assert.is.equal(expected, result)
  end)
end)
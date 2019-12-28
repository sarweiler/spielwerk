-- bragi core
-- 3 euclidean rhythms, 1 cv sequence


local CONFIG = {
  CV = {
    INITBPM = 45,
    STEPCOUNT = -1
  },
  SEQ = {
    INITBPM = 90,
    INITSTEPS = 20,
    INITPULSES = 13,
    STEPCOUNT = -1
  },
  SCALES = {},
  SCALES_MUSICUTIL = {
    {name = "Major", alt_names = {"Ionian"}, intervals = {0, 2, 4, 5, 7, 9, 11, 12}},
    {name = "Minor", alt_names = {"Minor", "Aeolian"}, intervals = {0, 2, 3, 5, 7, 8, 10, 12}},
    {name = "Chromatic", intervals = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}},
    {name = "Major Pentatonic", intervals = {0, 2, 4, 7, 9, 12}},
    {name = "Minor Pentatonic", intervals = {0, 3, 5, 7, 10, 12}}
  }
}

local state = {
  cv = {
    bpm = CONFIG.CV.INITBPM,
    metro = {},
    scale = "major",
    octave = 1,
    octave_range = 2
  },
  seqs = {
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = CONFIG.SEQ.INITPULSES + 2,
      sequence = {},
      bpm = CONFIG.SEQ.INITBPM,
      metro = {}
    },
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = CONFIG.SEQ.INITPULSES,
      sequence = {},
      bpm = CONFIG.SEQ.INITBPM,
      metro = {}
    },
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = CONFIG.SEQ.INITPULSES - 2,
      sequence = {},
      bpm = CONFIG.SEQ.INITBPM,
      metro = {}
    }
  }
}

local step,
      step_cv


-- some helper functions

local helper = {}
helper.tab = {}


-- stolen from https://github.com/monome/norns/blob/master/lua/lib/er.lua
helper.er_gen = function(p, s)
  -- results array, intially all zero
  local r = {}
  for i=1,s do r[i] = false end
  local b = s
  for i=1,s do
    if b >= s then
  b = b - s
  r[i] = true
    end
    b = b + p
  end
  return r
end

helper.quantize = function(scale, note)
  local note_round = math.floor(note) % 12
  if note_round <= 0 then
    return scale[1]
  end

  for i, scale_note in ipairs(scale) do
    if note_round < scale_note then
      return scale[i - 1]
    elseif note_round == scale_note then
      return scale_note
    end
  end
end

helper.preprocess_scales = function(scales)
  local scales_proc = {}
  for _, scale in pairs(scales) do
    scales_proc[scale.name:lower()] = scale.intervals
  end

  return scales_proc
end

helper.bpm_to_sec = function(bpm)
  return 60 / bpm
end

helper.sec_to_bpm = function(sec)
  return 60 / sec
end

helper.note_to_volt = function(note)
  return note / 12
end

helper.tab.shift_left = function(t)
  local t_clone = helper.tab.clone(t)
  table.insert(t_clone, #t_clone + 1, t_clone[1])
  table.remove(t_clone, 1)
  return t_clone
end

helper.tab.clone = function(t)
  return {table.unpack(t)}
end

helper.tab.debug = function(tab)
  print("---")
  for k,v in ipairs(tab) do
    print(k .. ": " .. tostring(v))
  end
end


-- bitwise operations on boolean tables

local tablebitwise = {}
local fill_tables


tablebitwise.tand = function(t1, t2)
  t1_filled, t2_filled = fill_tables(t1, t2)
  
  local result = {}
  for i=1, #t1_filled do
    result[i] = t1_filled[i] and t2_filled[i]
  end
  return result
end


tablebitwise.tor = function(t1, t2)
  t1_filled, t2_filled = fill_tables(t1, t2)
  
  local result = {}
  for i=1, #t1_filled do
    result[i] = t1_filled[i] or t2_filled[i]
  end
  return result
end


tablebitwise.to_int = function(t)
  t_binary = {}
  for i, val in ipairs(t) do
    t_binary[i] = t[i] and 1 or 0
  end
  return tonumber(table.concat(t_binary, ""), 2)
end


fill_tables = function(t1, t2)
  local t1_c = {table.unpack(t1)}
  local t2_c = {table.unpack(t2)}
  local len_diff = #t1_c - #t2_c
  if len_diff > 0 then
    for i=1,math.abs(len_diff) do
      table.insert(t2_c, 1, false)
    end
  elseif len_diff < 0 then
    for i=1,math.abs(len_diff) do
      table.insert(t1_c, 1, false)
    end
  end

  return t1_c, t2_c
end


-- accessor functions

acc = {}

acc.set_bpm = function(seq, bpm)
  state.seqs[seq].metro.time = helper.bpm_to_sec(bpm)
end

acc.get_bpm = function(seq)
  local bpm = helper.sec_to_bpm(state.seqs[seq].metro.time)
  print(bpm)
  return bpm
end

acc.set_steps = function(seq, steps)
  steps = steps >= state.seqs[seq].pulses and steps or state.seqs[seq].pulses
  state.seqs[seq].steps = steps
  state.seqs[seq].sequence = helper.er_gen(state.seqs[seq].pulses, state.seqs[seq].steps)
end

acc.set_pulses = function(seq, num_pulses)
  num_pulses = num_pulses <= state.seqs[seq].steps and num_pulses or state.seqs[seq].steps
  state.seqs[seq].pulses = num_pulses
  state.seqs[seq].sequence = helper.er_gen(state.seqs[seq].pulses, state.seqs[seq].steps)
end

acc.set_cv_bpm = function(bpm)
  state.seqs[seq].metro.time = helper.bpm_to_sec(bpm)
end

acc.set_scale = function(scale_name)
  state.cv.scale = scale_name:lower()
end


-- metro callbacks

step = function(c)
  if state.seqs[c].sequence[c] == true then
    output[c]()
  end
  state.seqs[c].sequence = helper.tab.shift_left(state.seqs[c].sequence)
end

step_cv = function()
  local cv_seq = tablebitwise.tand(
    tablebitwise.tand(
      state.seqs[1].sequence,
      state.seqs[2].sequence
    ),
    state.seqs[3].sequence
  )
  local bit_note_value = math.floor(tablebitwise.to_int(cv_seq) / 10000)
  local note_quantized = helper.quantize(CONFIG.SCALES[state.cv.scale], bit_note_value)
  local octave_range = math.random(state.cv.octave_range)
  local cv = helper.note_to_volt(
    (state.cv.octave * 12) + (octave_range * 12) + note_quantized
  )
  output[4].volts = cv
end


-- init

function init()
  CONFIG.SCALES = helper.preprocess_scales(CONFIG.SCALES_MUSICUTIL)

  for i=1,#state.seqs do
    output[i].action = { to(5,0), to(0, 0.25) }
    state.seqs[i].sequence = helper.er_gen(state.seqs[i].pulses, state.seqs[i].steps)
    state.seqs[i].metro = metro.init{
      event = function() step(i) end,
      time = helper.bpm_to_sec(state.seqs[i].bpm),
      count = CONFIG.SEQ.STEPCOUNT
    }
  end

  state.cv.metro = metro.init{
    event = step_cv,
    time = helper.bpm_to_sec(state.cv.bpm),
    count = CONFIG.CV.STEPCOUNT
  }

  for i=1,#state.seqs do
    state.seqs[i].metro:start()
  end

  state.cv.metro:start()

  print("hey")
end

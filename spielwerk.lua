-- spielwerk: 3 rhythms, 1 cv
-- 1.0.0 @sbaio
-- http://llllllll.co/
--
-- ENC 1: select menu item
-- ENC 2: set number of pulses
-- ENC 3: set number of steps
-- hold KEY 1 + ENC 1: set bpm

local er = require("er")
local menu_items = include("lib/src/norns/menu_items")
local par = include("lib/src/norns/parameters")
local cs = include("lib/src/crowservice")
local helpers = include("lib/src/helpers")
local tbw = include("lib/src/tablebitwise")

engine.name = "PolyPerc"

local cr, step, step_cv, update_ui

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
  },
  norns = {
    keys = {
      key1_down = false,
      key2_down = false,
      key3_down = false
    }
  }
}


local menu = {}

-- enc
function enc(n, delta)
  if n == 1 then
    if state.norns.keys.key1_down then
      if menu.active < 4 then
        par.callbacks.set_seq_bpm_delta(menu.active, delta, state)
      else
        par.callbacks.set_cv_bpm_delta(delta, state)
      end
    else
      menu.active = util.clamp(menu.active + delta, 1, #menu.items)
    end
  elseif n == 2 and menu.active < 4 then
    par.callbacks.set_seq_pulses_delta(menu.active, delta)
  elseif n == 3 and menu.active < 4  then
    par.callbacks.set_seq_steps_delta(menu.active, delta)
  end
  update_ui()
end


-- key
function key(n, pressed)
  if pressed == 1 then
    state.norns.keys["key" .. n .. "_down"] = true
  else
    state.norns.keys["key" .. n .. "_down"] = false
  end
end


-- display UI
update_ui = function()
  menu_items.update(menu)
  redraw()
end

function redraw()
  screen.clear()
  for i, item in ipairs(menu.items) do
    screen.move(0, i * 8)
    if menu.active == i then
      screen.level(15)
    else
      screen.level(7)
    end
    screen.text(item.name)
    screen.move(128, i * 8)
    screen.text_right(item.value)
  end
  
  screen.update()
end


-- metro callbacks
step = function(c)
  if state.seqs[c].sequence[c] == true then
    cr:fire_trigger(c)
  end
  state.seqs[c].sequence = helpers.tab.shift_left(state.seqs[c].sequence)
end

step_cv = function()
  local cv_seq = tbw.tand(
    tbw.tand(
      state.seqs[1].sequence,
      state.seqs[2].sequence
    ),
    state.seqs[3].sequence
  )
  local bit_note_value = math.floor(tbw.to_int(cv_seq) / 10000)
  local note_quantized = helpers.quantize(CONFIG.SCALES[state.cv.scale], bit_note_value)
  local octave_range = math.random(state.cv.octave_range)
  local cv = helpers.note_to_volt(
    (state.cv.octave * 12) + (octave_range * 12) + note_quantized
  )
  cr:set_cv(4, cv)
end


-- init
function init()
  -- crow init
  cr = cs:new(crow)
  cr:set_trigger_output(1)
  cr:set_trigger_output(2)
  cr:set_trigger_output(3)

  CONFIG.SCALES = helpers.preprocess_scales(CONFIG.SCALES_MUSICUTIL)

  for i, seq_state in ipairs(state.seqs) do
    cr:set_trigger_output(i)
    seq_state.sequence = helpers.er_gen(state.seqs[i].pulses, state.seqs[i].steps)
    seq_state.metro = metro.init{
      event = function() step(i) end,
      time = helpers.bpm_to_sec(state.seqs[i].bpm),
      count = CONFIG.SEQ.STEPCOUNT
    }
  end

  state.cv.metro = metro.init{
    event = step_cv,
    time = helpers.bpm_to_sec(state.cv.bpm),
    count = CONFIG.CV.STEPCOUNT
  }

  for i=1,#state.seqs do
    state.seqs[i].metro:start()
  end

  state.cv.metro:start()

  menu.active = 1
  par.add_params(par.callbacks, state)
  update_ui()
end
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

engine.name = "PolyPerc"

local update_ui

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


-- init
function init()
  menu.active = 1
  par.add_params(par.callbacks, state)
  update_ui()
end
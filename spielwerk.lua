-- spielwerk: 2 rhythms, 2 cvs
-- 0.9.0 @sbaio
-- http://llllllll.co/
--
-- ENC 1: select menu item
-- ENC 2: set number of pulses
-- ENC 3: set number of steps
-- hold KEY 1 + ENC 1: set bpm

local er = require("er")
local mu = require("musicutil")
local par = include("lib/src/parameters")
local as = include("lib/src/arcservice")
local cs = include("lib/src/crowservice")
local helpers = include("lib/src/helpers")
local tbw = include("lib/src/tablebitwise")
local state = include("lib/src/state")

local CONFIG = include("lib/src/config")

engine.name = "PolyPerc"

local a, calc_cv_value, cr, step, step_cv, update_ui

local menu = {}

local callbacks = {
  set_cv_bpm = function(i, new_value)
    params:set("cv" .. i .. "_bpm", new_value)
    state.update()
  end,
  set_cv_bpm_delta = function(i, delta)
    local current_value = params:get("cv" .. i .. "_bpm")
    params:set("cv" .. i .. "_bpm", current_value + delta)
    state.update()
  end,
  set_seq_bpm = function(i, new_value)
    local id = "seq" .. i .. "_bpm"
    params:set(id, new_value)
    state.update()
  end,
  set_seq_bpm_delta = function(i, delta)
    local id = "seq" .. i .. "_bpm"
    local current_value = params:get(id)
    local new_value = current_value + delta
    params:set(id, new_value)
    state.update()
  end,
  set_seq_pulses = function(i, new_value)
    local id = "seq" .. i .. "_pulses"
    local steps = params:get("seq" .. i .. "_steps")
    if new_value > steps then
      new_value = steps
    end
    params:set(id, new_value)
    state.update()
  end,
  set_seq_pulses_delta = function(i, delta)
    local id = "seq" .. i .. "_pulses"
    local current_value = params:get(id)
    local new_value = current_value + delta
    local steps = params:get("seq" .. i .. "_steps")
    if new_value > steps then
      new_value = steps
    end
    params:set(id, new_value)
    state.update()
  end,
  set_seq_steps = function(i, new_value)
    local id = "seq" .. i .. "_steps"
    local pulses = params:get("seq" .. i .. "_pulses")
    if new_value < pulses then
      new_value = pulses
    end
    params:set(id, new_value)
    state.update()
  end,
  set_seq_steps_delta = function(i, delta)
    local id = "seq" .. i .. "_steps"
    local current_value = params:get(id)
    local new_value = current_value + delta
    local pulses = params:get("seq" .. i .. "_pulses")
    if new_value < pulses then
      new_value = pulses
    end
    params:set(id, new_value)
    state.update()
  end,
  set_jf_output = function(v)
    if v==1 then
      crow.ii.pullup(true)
      crow.ii.jf.mode(1)
    else
      crow.ii.pullup(false)
      crow.ii.jf.mode(0)
    end
  end,
  set_cutoff = function()
    engine.cutoff(params:get("cutoff"))
    state.update()
  end
}


-- enc
function enc(n, delta)
  if n == 1 then
    if state.norns.keys.key1_down then
      if state.menu.active < 3 then
        callbacks.set_seq_bpm_delta(state.menu.active, delta)
      else
        callbacks.set_cv_bpm_delta(state.menu.active - 2, delta)
      end
    else
      state.menu.active = util.clamp(state.menu.active + delta, 1, state.menu.items)
    end
  elseif n == 2 and state.menu.active < 3 then
    callbacks.set_seq_pulses_delta(state.menu.active, delta)
  elseif n == 3 and state.menu.active < 3  then
    callbacks.set_seq_steps_delta(state.menu.active, delta)
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

  if state.norns.keys.key1_down and state.norns.keys.key2_down then
    if state.menu.active < 3 then
      state.seqs[state.menu.active].metro:stop()
    else
      state.cv_seqs[state.menu.active - 2].metro:stop()
    end
  end

  if state.norns.keys.key1_down and state.norns.keys.key3_down then
    if state.menu.active < 3 then
      state.seqs[state.menu.active].metro:start()
    else
      state.cv_seqs[state.menu.active - 2].metro:start()
    end
  end
end


calc_cv_value = function(cv_seq)
  local bit_note_value = math.floor(tbw.to_int(cv_seq) / 10000)
  local note_quantized = helpers.quantize(CONFIG.SCALES[state.scale], bit_note_value)
  local octave_range = math.random(params:get("octave_range"))
  local cv = helpers.note_to_volt(
    (params:get("octave") * 12) + (octave_range * 12) + note_quantized
  )

  return cv
end


-- display UI
update_ui = function()
  a:redraw()
  redraw()
end

function redraw()
  screen.clear()
  local line_height = 16

  for i, seq in ipairs(state.seqs) do
    screen.move(128, i * line_height - 8)
    screen.level(state.menu.active == i and 15 or 4)
    local id_bpm = "seq" .. i .. "_bpm"
    local id_pulses = "seq" .. i .. "_pulses"
    local id_steps = "seq" .. i .. "_steps"
    screen.font_size(8)
    screen.text_right("s" .. i .. " | " .. "bpm: " .. params:get(id_bpm) .. " | p: " .. params:get(id_pulses) .. " | s: " .. params:get(id_steps))
    for j, step in ipairs(seq.sequence) do
      if(step == true) then
        screen.level(10)
      else
        screen.level(4)
      end

      if j == seq.active then
        screen.level(15)
      end
      screen.rect(128 - (#seq.sequence * 2) + (j * 2), (i * line_height) - 4, 2, 4)
      screen.fill()
    end
  end

  for i, seq in ipairs(state.cv_seqs) do
    screen.level(state.menu.active == (i + 2) and 15 or 4)
    screen.move(128, (#state.seqs + i) * line_height - 4)
    screen.text_right("cv" .. i .. " bpm: " .. params:get("cv" .. i .. "_bpm"))
  end
  
  screen.update()
end


-- metro callbacks
step = function(c)
  local active_step = state.seqs[c].active
  if state.seqs[c].sequence[active_step] == true then
    cr:fire_trigger(c + 1)
  end
  state.seqs[c].active = (state.seqs[c].active < state.seqs[c].steps) and state.seqs[c].active + 1 or 1
  state.seqs[c].sequence_shifted = helpers.tab.shift_left(state.seqs[c].sequence_shifted)

  a:display_sequence{
    ring = c + 1,
    seq = state.seqs[c].sequence,
    active = state.seqs[c].active
  }

  update_ui()
end

step_cv = function(i)
  local cv_seq_and = tbw.tand(
      state.seqs[1].sequence_shifted,
      state.seqs[2].sequence_shifted
  )
  
  local cv_and = calc_cv_value(cv_seq_and)

  local cv_seq_or = tbw.tor(
      state.seqs[1].sequence_shifted,
      state.seqs[2].sequence_shifted
  )
  local cv_or = calc_cv_value(cv_seq_or)
  
  if i == 1 then
    state.cv_seqs[1].value = cv_or
    cr:set_cv(1, cv_or)
    a:display_cv{
      ring = 1,
      cv = state.cv_seqs[1].value
    }
  else
    state.cv_seqs[2].value = cv_and
    cr:set_cv(4, cv_and)
    a:display_cv{
      ring = 4,
      cv = state.cv_seqs[2].value
    }
  end

  if params:get("jf_output") == 1 then
    if params:get("jf_note_mode") == 1 then
      crow.ii.jf.play_note(cv_and + CONFIG.JF.OCTAVE_OFFSET, 4.0)
    elseif params:get("jf_note_mode") == 2 then
      crow.ii.jf.play_note(cv_or + CONFIG.JF.OCTAVE_OFFSET, 4.0)
    end
  end

  update_ui()
end


-- init
function init()
  -- crow init
  cr = cs:new(crow)

  -- arc init
  a = as:new(arc)

  a:set_delta_fn{
    ring = 1,
    fn = function(d)
      callbacks.set_cv_bpm_delta(1, d)
    end
  }

  for i, seq_state in ipairs(state.seqs) do
    a:set_delta_fn{
      ring = i + 1,
      fn = function(d)
        if state.norns.keys.key2_down then
          callbacks.set_seq_pulses_delta(i, d)
        elseif state.norns.keys.key3_down then
          callbacks.set_seq_steps_delta(i, d)
        else
          callbacks.set_seq_bpm_delta(i, d)
        end
      end
    }
  end

  a:set_delta_fn{
    ring = 4,
    fn = function(d)
      callbacks.set_cv_bpm_delta(2, d)
    end
  }

  CONFIG.SCALES = helpers.preprocess_scales(CONFIG.SCALES_MUSICUTIL)

  cr:set_trigger_output(2)
  cr:set_trigger_output(3)

  for i, seq_state in ipairs(state.seqs) do
    seq_state.sequence = er.gen(state.seqs[i].pulses, state.seqs[i].steps)
    seq_state.sequence_shifted = seq_state.sequence
    seq_state.metro = metro.init{
      event = function() step(i) end,
      time = helpers.bpm_to_sec(state.seqs[i].bpm),
      count = CONFIG.SEQ.STEPCOUNT
    }
  end

  for i, seq_state in ipairs(state.cv_seqs) do
    state.cv_seqs[i].metro = metro.init{
      event = function() step_cv(i) end,
      time = helpers.bpm_to_sec(state.cv_seqs[i].bpm),
      count = CONFIG.CV.STEPCOUNT
    }
  end

  for i=1,#state.seqs do
    state.seqs[i].metro:start()
  end

  for i=1,#state.cv_seqs do
    state.cv_seqs[i].metro:start()
  end

  state.menu.active = 1
  par.add_params(callbacks, state)
  update_ui()
end
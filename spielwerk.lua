-- spielwerk: 3 rhythms, 1 cv
-- 1.0.0 @sbaio
-- http://llllllll.co/
--
-- ENC 1: select menu item
-- ENC 2: set number of pulses
-- ENC 3: set number of steps
-- hold KEY 1 + ENC 1: set bpm

local er = require("er")
local mu = require("musicutil")
local par = include("lib/src/norns/parameters")
local as = include("lib/src/arcservice")
local cs = include("lib/src/crowservice")
local helpers = include("lib/src/helpers")
local tbw = include("lib/src/tablebitwise")

engine.name = "PolyPerc"

local a, calc_cv_value, cr, step, step_cv, update_arc, update_state, update_ui

local CONFIG = {
  CV = {
    INITBPM = 45,
    STEPCOUNT = -1
  },
  JF = {
    OCTAVE_OFFSET = -3
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
    value = 0
  },
  seqs = {
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = CONFIG.SEQ.INITPULSES,
      sequence = {},
      sequence_shifted = {},
      active = 1,
      bpm = CONFIG.SEQ.INITBPM,
      metro = {}
    },
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = CONFIG.SEQ.INITPULSES,
      sequence = {},
      sequence_shifted = {},
      active = 1,
      bpm = CONFIG.SEQ.INITBPM,
      metro = {}
    },
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = CONFIG.SEQ.INITPULSES,
      sequence = {},
      sequence_shifted = {},
      active = 1,
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
  },
  menu = {
    active = 1,
    items = 4
  }
}

local menu = {}

local callbacks = {
  set_cv_bpm = function(new_value)
    params:set("cv_bpm", new_value)
    update_state()
  end,
  set_cv_bpm_delta = function(delta)
    local current_value = params:get("cv_bpm")
    params:set("cv_bpm", current_value + delta)
    update_state()
  end,
  set_seq_bpm = function(i, new_value)
    local id = "seq" .. i .. "_bpm"
    params:set(id, new_value)
    update_state()
  end,
  set_seq_bpm_delta = function(i, delta)
    local id = "seq" .. i .. "_bpm"
    local current_value = params:get(id)
    local new_value = current_value + delta
    params:set(id, new_value)
    update_state()
  end,
  set_seq_pulses = function(i, new_value)
    local id = "seq" .. i .. "_pulses"
    local steps = params:get("seq" .. i .. "_steps")
    if new_value > steps then
      new_value = steps
    end
    params:set(id, new_value)
    update_state()
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
    update_state()
  end,
  set_seq_steps = function(i, new_value)
    local id = "seq" .. i .. "_steps"
    local pulses = params:get("seq" .. i .. "_pulses")
    if new_value < pulses then
      new_value = pulses
    end
    params:set(id, new_value)
    update_state()
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
    update_state()
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
    update_state()
  end
}

-- state
update_state = function()
  for i, seq_state in ipairs(state.seqs) do
    local id_bpm = "seq" .. i .. "_bpm"
    local id_pulses = "seq" .. i .. "_pulses"
    local id_steps = "seq" .. i .. "_steps"
    state.seqs[i].metro.time = helpers.bpm_to_sec(params:get(id_bpm))
    state.seqs[i].bpm = params:get(id_bpm)
    state.seqs[i].pulses = params:get(id_pulses)
    state.seqs[i].steps = params:get(id_steps)
    state.seqs[i].sequence = er.gen(state.seqs[i].pulses, state.seqs[i].steps)
  end

  state.cv.bpm = params:get("cv_bpm")
  state.cv.metro.time = helpers.bpm_to_sec(params:get("cv_bpm"))
end


-- enc
function enc(n, delta)
  if n == 1 then
    if state.norns.keys.key1_down then
      if state.menu.active < 4 then
        callbacks.set_seq_bpm_delta(state.menu.active, delta)
      else
        callbacks.set_cv_bpm_delta(delta, state)
      end
    else
      state.menu.active = util.clamp(state.menu.active + delta, 1, state.menu.items)
    end
  elseif n == 2 and state.menu.active < 4 then
    callbacks.set_seq_pulses_delta(state.menu.active, delta)
  elseif n == 3 and state.menu.active < 4  then
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
    for i, seq in ipairs(state.seqs) do
      seq.metro:stop()
    end
    state.cv.metro:stop()
  end

  if state.norns.keys.key1_down and state.norns.keys.key3_down then
    for i, seq in ipairs(state.seqs) do
      seq.metro:start()
    end
    state.cv.metro:start()
  end
end


calc_cv_value = function(cv_seq)
  local bit_note_value = math.floor(tbw.to_int(cv_seq) / 10000)
  local note_quantized = helpers.quantize(CONFIG.SCALES[state.cv.scale], bit_note_value)
  local octave_range = math.random(params:get("octave_range"))
  local cv = helpers.note_to_volt(
    (params:get("octave") * 12) + (octave_range * 12) + note_quantized
  )

  return cv
end

update_arc = function()
  for i, seq_state in ipairs(state.seqs) do
    a:display_sequence{
      ring = i,
      seq = seq_state.sequence,
      active = seq_state.active
    }
  end

  a:display_cv{
    ring = 4,
    cv = state.cv.value
  }
  
  a:redraw()
end

-- display UI
update_ui = function()
  update_arc()
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

  screen.level(state.menu.active == 4 and 15 or 4)
  screen.move(128, (#state.seqs + 1) * line_height - 4)
  screen.text_right("cv bpm: " .. params:get("cv_bpm"))
  
  screen.update()
end


-- metro callbacks
step = function(c)
  local active_step = state.seqs[c].active
  if state.seqs[c].sequence[active_step] == true then
    cr:fire_trigger(c)
  end
  state.seqs[c].active = (state.seqs[c].active < state.seqs[c].steps) and state.seqs[c].active + 1 or 1
  state.seqs[c].sequence_shifted = helpers.tab.shift_left(state.seqs[c].sequence_shifted)
  update_ui()
end

step_cv = function()
  local cv_seq_and = tbw.tand(
    tbw.tand(
      state.seqs[1].sequence_shifted,
      state.seqs[2].sequence_shifted
    ),
    state.seqs[3].sequence_shifted
  )
  local cv_and = calc_cv_value(cv_seq_and)
  state.cv.value = cv_and
  cr:set_cv(4, cv_and)

  if params:get("jf_output") == 1 then
    if params:get("jf_note_mode") == 1 then
      crow.ii.jf.play_note(cv_and + CONFIG.JF.OCTAVE_OFFSET, 4.0)
    elseif params:get("jf_note_mode") == 2 then
      local cv_seq_or_and = tbw.tand(
        tbw.tor(
          state.seqs[1].sequence_shifted,
          state.seqs[2].sequence_shifted
        ),
        state.seqs[3].sequence_shifted
      )
      local cv_or_and = calc_cv_value(cv_seq_or_and)
      crow.ii.jf.play_note(cv_or_and + CONFIG.JF.OCTAVE_OFFSET, 4.0)
      elseif params:get("jf_note_mode") == 3 then
        local cv_seq_and_or = tbw.tor(
          tbw.tand(
            state.seqs[1].sequence_shifted,
            state.seqs[2].sequence_shifted
          ),
          state.seqs[3].sequence_shifted
        )
        local cv_and_or = calc_cv_value(cv_seq_and_or)
        crow.ii.jf.play_note(cv_and_or + CONFIG.JF.OCTAVE_OFFSET, 4.0)
    elseif params:get("jf_note_mode") == 4 then
      local cv_seq_or_or = tbw.tor(
        tbw.tor(
          state.seqs[1].sequence_shifted,
          state.seqs[2].sequence_shifted
        ),
        state.seqs[3].sequence_shifted
      )
      local cv_or_or = calc_cv_value(cv_seq_or_or)
      crow.ii.jf.play_note(cv_or_or + CONFIG.JF.OCTAVE_OFFSET, 4.0)
    end
  end
end


-- init
function init()
  -- crow init
  cr = cs:new(crow)

  -- arc init
  a = as:new(arc)

  for i=1, 3 do
    a:set_delta_fn{
      ring = i,
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
      callbacks.set_cv_bpm_delta(d)
    end
  }

  CONFIG.SCALES = helpers.preprocess_scales(CONFIG.SCALES_MUSICUTIL)

  for i, seq_state in ipairs(state.seqs) do
    cr:set_trigger_output(i)
    seq_state.sequence = er.gen(state.seqs[i].pulses, state.seqs[i].steps)
    seq_state.sequence_shifted = seq_state.sequence
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

  state.menu.active = 1
  par.add_params(callbacks, state)
  update_ui()
end
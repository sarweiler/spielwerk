local er = require("er")
local CONFIG = include("lib/src/config")
local helpers = include("lib/src/helpers")

local state = {
  scale = "major",
  cv_seqs = {
    {
      bpm = CONFIG.CV.INITBPM,
      metro = {},
      value = 0
    },
    {
      bpm = CONFIG.CV.INITBPM,
      metro = {},
      value = 0
    },
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

state.update = function()
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

  for i, cv_seq_state in ipairs(state.cv_seqs) do
    state.cv_seqs[i].bpm = params:get("cv" .. i .. "_bpm")
    state.cv_seqs[i].metro.time = helpers.bpm_to_sec(params:get("cv" .. i .. "_bpm"))
  end
end

return state
local parameters = {
  add_params = function(param_callbacks, state)
    for i, cv_seq_state in ipairs(state.cv_seqs) do
      local cs_bpm_cv = controlspec.new(1, 300, 'lin', 1, cv_seq_state.bpm, 'bpm')
      params:add{
        type="control",
        id="cv" .. i .. "_bpm",
        controlspec=cs_bpm_cv,
        action=function(v) param_callbacks.set_cv_bpm(i, v) end
      }
    end

    for i, seq_state in ipairs(state.seqs) do
      local id_bpm = "seq" .. i .. "_bpm"
      local id_pulses = "seq" .. i .. "_pulses"
      local id_steps = "seq" .. i .. "_steps"

      local cs_seq_bpm = controlspec.new(1, 300, 'lin', 1, seq_state.bpm, 'bpm')
      local cs_seq_pulses = controlspec.new(1, 64, 'lin', 1, seq_state.pulses, '')
      local cs_seq_steps = controlspec.new(1, 64, 'lin', 1, seq_state.steps, '')

      params:add{
        type="control",
        id=id_bpm,
        controlspec=cs_seq_bpm,
        action=function(v) param_callbacks.set_seq_bpm(i, v) end
      }

      params:add{
        type="control",
        id=id_pulses,
        controlspec=cs_seq_pulses,
        action=function(v) param_callbacks.set_seq_pulses(i, v) end
      }
      
      params:add{
        type="control",
        id=id_steps,
        controlspec=cs_seq_steps,
        action=function(v) param_callbacks.set_seq_steps(i, v) end
      }
    end

    local cs_co = controlspec.new(50, 5000, "exp", 0, 1000, "hz")
    params:add{
      type="control",
      id="cutoff",
      controlspec=cs_co,
      action=param_callbacks.set_cutoff
    }

    local cs_octave = controlspec.new(1, 5, "lin", 1, 2, "")
    params:add{
      type="control",
      id="octave",
      controlspec=cs_octave
    }

    local cs_octave_range = controlspec.new(1, 5, "lin", 1, 1, "")
    params:add{
      type="control",
      id="octave_range",
      controlspec=cs_octave_range
    }

    params:add_option(
      "jf_output",
      "jf output",
      {"y", "n"},
      2
    )
    params:set_action("jf_output", function(v) param_callbacks.set_jf_output(v) end)

    params:add_option(
      "jf_note_mode",
      "jf note mode",
      {"and", "or"},
      2
    )
  end
}

return parameters
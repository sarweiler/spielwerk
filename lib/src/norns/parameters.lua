local parameters = {
  add_params = function(param_callbacks, state)
    local cs_bpm_cv = controlspec.new(1, 300, 'lin', 1, state.cv.bpm, 'bpm')
    params:add{
      type="control",
      id="cv_bpm",
      controlspec=cs_bpm_cv,
      action=param_callbacks.set_cv_bpm
    }

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
  end
}

return parameters
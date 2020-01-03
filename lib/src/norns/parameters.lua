local parameters = {
  callbacks = {
    set_cv_bpm = function(new_value)
      params:set("cv_bpm", new_value)
    end,
    set_cv_bpm_delta = function(delta)
      local current_value = params:get("cv_bpm")
      params:set("cv_bpm", current_value + delta)
    end,
    set_seq_bpm = function(i, new_value)
      local id = "seq" .. i .. "_bpm"
      params:set(id, new_value)
    end,
    set_seq_bpm_delta = function(i, delta)
      local id = "seq" .. i .. "_bpm"
      local current_value = params:get(id)
      params:set(id, current_value + delta)
    end,
    set_seq_pulses = function(i, new_value)
      local id = "seq" .. i .. "_pulses"
      params:set(id, new_value)
    end,
    set_seq_pulses_delta = function(i, delta)
      local id = "seq" .. i .. "_pulses"
      local current_value = params:get(id)
      params:set(id, current_value + delta)
    end,
    set_seq_steps = function(i, new_value)
      local id = "seq" .. i .. "_steps"
      params:set(id, new_value)
    end,
    set_seq_steps_delta = function(i, delta)
      local id = "seq" .. i .. "_steps"
      local current_value = params:get(id)
      params:set(id, current_value + delta)
    end,
    set_cutoff = function()
      engine.cutoff(params:get("cutoff"))
    end
  },

  add_params = function(param_callbacks)
    local cs_bpm_cv = controlspec.new(1, 300, 'lin', 1, 50, 'bpm')
    params:add{
      type="control",
      id="cv_bpm",
      controlspec=cs_bpm_cv,
      action=param_callbacks.set_cv_bpm
    }


    local cs_seq1_bpm = controlspec.new(1, 300, 'lin', 1, 50, 'bpm')
    params:add{
      type="control",
      id="seq1_bpm",
      controlspec=cs_seq1_bpm,
      action=function(v) param_callbacks.set_seq_bpm(1, v) end
    }

    local cs_seq1_pulses = controlspec.new(1, 64, 'lin', 1, 20, '')
    params:add{
      type="control",
      id="seq1_pulses",
      controlspec=cs_seq1_pulses,
      action=function(v) param_callbacks.set_seq_pulses(1, v) end
    }

    local cs_seq1_steps = controlspec.new(1, 64, 'lin', 1, 20, '')
    params:add{
      type="control",
      id="seq1_steps",
      controlspec=cs_seq1_steps,
      action=function(v) param_callbacks.set_seq_steps(1, v) end
    }


    local cs_seq2_bpm = controlspec.new(1, 300, 'lin', 1, 50, 'bpm')
    params:add{
      type="control",
      id="seq2_bpm",
      controlspec=cs_seq2_bpm,
      action=function(v) param_callbacks.set_seq_bpm(2, v) end
    }

    local cs_seq2_pulses = controlspec.new(1, 64, 'lin', 1, 20, '')
    params:add{
      type="control",
      id="seq2_pulses",
      controlspec=cs_seq2_pulses,
      action=function(v) param_callbacks.set_seq_pulses(2, v) end
    }

    local cs_seq2_steps = controlspec.new(1, 64, 'lin', 1, 20, '')
    params:add{
      type="control",
      id="seq2_steps",
      controlspec=cs_seq2_steps,
      action=function(v) param_callbacks.set_seq_steps(2, v) end
    }


    local cs_seq3_bpm = controlspec.new(1, 300, 'lin', 1, 50, 'bpm')
    params:add{
      type="control",
      id="seq3_bpm",
      controlspec=cs_seq3_bpm,
      action=function(v) param_callbacks.set_seq_bpm(3, v) end
    }

    local cs_seq3_pulses = controlspec.new(1, 64, 'lin', 1, 20, '')
    params:add{
      type="control",
      id="seq3_pulses",
      controlspec=cs_seq3_pulses,
      action=function(v) param_callbacks.set_seq_pulses(3, v) end
    }

    local cs_seq3_steps = controlspec.new(1, 64, 'lin', 1, 20, '')
    params:add{
      type="control",
      id="seq3_steps",
      controlspec=cs_seq3_steps,
      action=function(v) param_callbacks.set_seq_steps(3, v) end
    }


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
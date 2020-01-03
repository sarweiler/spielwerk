local menu_items = {
  update = function(menu)
    menu.items = {
      {
        name = "s1",
        value = string.format("bpm: %3d / p: %2d / s: %2d", params:get("seq1_bpm"), params:get("seq1_pulses"), params:get("seq1_steps"))
      },
      {
        name = "s2",
        value = string.format("bpm: %3d / p: %2d / s: %2d", params:get("seq2_bpm"), params:get("seq2_pulses"), params:get("seq2_steps"))
      },
      {
        name = "s3",
        value = string.format("bpm: %3d / p: %2d / s: %2d", params:get("seq3_bpm"), params:get("seq3_pulses"), params:get("seq3_steps"))
      },
      {
        name = "cv",
        value = string.format("bpm: %3d", params:get("cv_bpm"))
      }
    }
  end
}

return menu_items
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

return CONFIG
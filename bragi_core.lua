-- bragi core
-- 3 euclidean rhythms, 1 cv sequence


local CONFIG = {
  SEQ = {
    INITSTEPS = 20,
    STEPCOUNT = 90
  }
}

local state = {
  seqs = {
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = 20,
      sequence = {},
      bpm = 95
    },
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = 20,
      sequence = {},
      bpm = 90
    },
    {
      steps = CONFIG.SEQ.INITSTEPS,
      pulses = 20,
      sequence = {},
      bpm = 90
    }
  }
}

-- functions
local bpm_to_sec,
      bitwise,
      debug_tab,
      er_gen,
      shift_seq,
      step,
      tab_clone,
      tab_shift
      

-- Euclidean rhythm (http://en.wikipedia.org/wiki/Euclidean_Rhythm)
-- @param p : number of pulses
-- @param s : total number of steps
-- stolen from https://github.com/monome/norns/blob/master/lua/lib/er.lua
er_gen = function(p, s)
  -- results array, intially all zero
  local r = {}
  for i=1,s do r[i] = false end
  local b = s
  for i=1,s do
    if b >= s then
  b = b - s
  r[i] = true
    end
    b = b + p
  end
  return r
end


bpm_to_sec = function(bpm)
  return 60 / bpm / 4
end


tab_shift = function(t)
  local t_clone = tab_clone(t)
  table.insert(t_clone, 1, t_clone[#t_clone])
  table.remove(t_clone, #t_clone)
  return t_clone
end


tab_clone = function(t)
  return {table.unpack(t)}
end


shift_seq = function(seq)
  local seq_clone = tab_clone(seq)
  return tab_shift(seq_clone)
end


debug_tab = function(tab)
  print("---")
  for k,v in ipairs(tab) do
    print(k .. ": " .. tostring(v))
  end
end


step = function(c)
  if state.seqs[c].sequence[c] == true then
    output[c]()
  end
  state.seqs[c].sequence = shift_seq(state.seqs[c].sequence)
end


-- init
function init()
  for i=1,#state.seqs do
    output[i].action = { to(5,0), to(0, 0.25) }
    state.seqs[i].sequence = er_gen(state.seqs[i].pulses, state.seqs[i].steps)
    state.seqs[i].metro = metro.init{
      event = function() step(i) end,
      time = bpm_to_sec(state.seqs[i].bpm),
      count = CONFIG.SEQ.STEPCOUNT
    }
  end

  for i=1,#state.seqs do
    state.seqs[i].metro:start()
  end

  print("hey")
end

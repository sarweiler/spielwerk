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
      

-- some helper functions

local helper = {}
helper.tab = {}


-- stolen from https://github.com/monome/norns/blob/master/lua/lib/er.lua
helper.er_gen = function(p, s)
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

helper.bpm_to_sec = function(bpm)
  return 60 / bpm / 4
end

helper.tab.shift_left = function(t)
  local t_clone = helper.tab.clone(t)
  table.insert(t_clone, #t_clone + 1, t_clone[1])
  table.remove(t_clone, 1)
  return t_clone
end

helper.tab.shift_right = function(t)
  local t_clone = helper.tab.clone(t)
  table.insert(t_clone, 1, t_clone[#t_clone])
  table.remove(t_clone, #t_clone)
  return t_clone
end

helper.tab.clone = function(t)
  return {table.unpack(t)}
end

helper.tab.debug = function(tab)
  print("---")
  for k,v in ipairs(tab) do
    print(k .. ": " .. tostring(v))
  end
end


step = function(c)
  if state.seqs[c].sequence[c] == true then
    output[c]()
  end
  state.seqs[c].sequence = helper.tab.shift_left(state.seqs[c].sequence)
end


-- init
function init()
  for i=1,#state.seqs do
    output[i].action = { to(5,0), to(0, 0.25) }
    state.seqs[i].sequence = helper.er_gen(state.seqs[i].pulses, state.seqs[i].steps)
    state.seqs[i].metro = metro.init{
      event = function() step(i) end,
      time = helper.bpm_to_sec(state.seqs[i].bpm),
      count = CONFIG.SEQ.STEPCOUNT
    }
  end

  for i=1,#state.seqs do
    state.seqs[i].metro:start()
  end

  print("hey")
end

-- some helpers functions

local helpers = {}
helpers.tab = {}


-- stolen from https://github.com/monome/norns/blob/master/lua/lib/er.lua
helpers.er_gen = function(p, s)
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

helpers.quantize = function(scale, note)
  local note_round = math.floor(note) % 12
  if note_round <= 0 then
    return scale[1]
  end

  for i, scale_note in ipairs(scale) do
    if note_round < scale_note then
      return scale[i - 1]
    elseif note_round == scale_note then
      return scale_note
    end
  end
end

helpers.preprocess_scales = function(scales)
  local scales_proc = {}
  for _, scale in pairs(scales) do
    scales_proc[scale.name:lower()] = scale.intervals
  end

  return scales_proc
end

helpers.bpm_to_sec = function(bpm)
  return 60 / bpm
end

helpers.sec_to_bpm = function(sec)
  return 60 / sec
end

helpers.note_to_volt = function(note)
  return note / 12
end

helpers.tab.shift_left = function(t)
  local t_clone = helpers.tab.clone(t)
  table.insert(t_clone, #t_clone + 1, t_clone[1])
  table.remove(t_clone, 1)
  return t_clone
end

helpers.tab.shift_right = function(t)
  local t_clone = helpers.tab.clone(t)
  table.insert(t_clone, 1, t_clone[#t_clone])
  table.remove(t_clone, #t_clone)
  return t_clone
end

helpers.tab.clone = function(t)
  return {table.unpack(t)}
end

helpers.tab.debug = function(tab)
  print("---")
  for k,v in ipairs(tab) do
    print(k .. ": " .. tostring(v))
  end
end


return helpers
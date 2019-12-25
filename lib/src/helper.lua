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

helper.sec_to_bpm = function(sec)
  return 60 / sec / 4
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


return helper
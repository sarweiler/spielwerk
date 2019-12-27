-- bitwise operations on boolean tables


local tablebitwise = {}
local fill_tables


tablebitwise.tand = function(t1, t2)
  t1_filled, t2_filled = fill_tables(t1, t2)
  
  local result = {}
  for i=1, #t1_filled do
    result[i] = t1_filled[i] and t2_filled[i]
  end
  return result
end


tablebitwise.tor = function(t1, t2)
  t1_filled, t2_filled = fill_tables(t1, t2)
  
  local result = {}
  for i=1, #t1_filled do
    result[i] = t1_filled[i] or t2_filled[i]
  end
  return result
end


tablebitwise.to_int = function(t)
  t_binary = {}
  for i, val in ipairs(t) do
    t_binary[i] = t[i] and 1 or 0
  end
  return tonumber(table.concat(t_binary, ""), 2)
end


fill_tables = function(t1, t2)
  local t1_c = {table.unpack(t1)}
  local t2_c = {table.unpack(t2)}
  local len_diff = #t1_c - #t2_c
  if len_diff > 0 then
    for i=1,math.abs(len_diff) do
      table.insert(t2_c, 1, false)
    end
  elseif len_diff < 0 then
    for i=1,math.abs(len_diff) do
      table.insert(t1_c, 1, false)
    end
  end

  return t1_c, t2_c
end


return tablebitwise
local archelpers = {}

archelpers.display_sequence = function(arg)
  local r = arg.ring
  local seq = arg.seq
  local a = arg.arc
  for i, step in ipairs(seq) do
    print("arc step" .. i)
    a:led(r, i, step == true and 15 or 4)
  end
end

return archelpers
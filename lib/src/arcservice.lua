-- talking to arc

local ArcService = {}
ArcService.__index = ArcService

local connect, init_delta_callbacks

function ArcService:new(arc_ref)
  local as = {}
  as.arc = connect(arc_ref)
  as.delta_callbacks = {}
  setmetatable(as, self)
  init_delta_callbacks(as)
  return as
end

function ArcService:set_delta_fn(arg)
  local r = arg.ring
  local fn = arg.fn
  self.delta_callbacks[arg.ring] = arg.fn
end

function ArcService:display_sequence(arg)
  local r = arg.ring
  local seq = arg.seq
  for i, step in ipairs(seq) do
    self.arc:led(r, i, 12)
  end
end

function ArcService:redraw(state)
  self.arc:refresh()
end

connect = function(arc_ref)
  return arc_ref.connect()
end

init_delta_callbacks = function(as)
  as.arc.delta = function(n, d)
    as.delta_callbacks[n](d)
  end
end

return ArcService

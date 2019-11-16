-- talking to arc

local ArcService = {}
ArcService.__index = ArcService

local init_delta_callbacks

function ArcService:new(arc_ref)
  local as = {}
  as.arc = arc_ref
  as.delta_callbacks = {}
  setmetatable(as, self)
  init_delta_callbacks(as)
  return as
end

function ArcService:connect()
  self.arc.connect()
end

function ArcService:set_delta_fn(arg)
  local r = arg.ring
  local fn = arg.fn
  self.delta_callbacks[arg.ring] = arg.fn
end

function ArcService:redraw(state)
  -- redraw
end

init_delta_callbacks = function(as)
  as.arc.delta = function(n, d)
    as.delta_callbacks[n](d)
  end
end

return ArcService

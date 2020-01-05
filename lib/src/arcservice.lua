-- talking to arc

local ArcService = {}
ArcService.__index = ArcService

local connect, init_delta_callbacks

function ArcService:new(arc_ref)
  local as = {}
  as.arc = connect(arc_ref)
  as.delta_callbacks = {}
  as.CONFIG = {
    RING_STEPS = 64,
    BRIGHTNESS = {
      ACTIVE = 15,
      PULSE = 11,
      STEP = 4,
      CV = 11
    }
  }
  setmetatable(as, self)
  init_delta_callbacks(as)
  return as
end

function ArcService:set_delta_fn(arg)
  local r = arg.ring
  local fn = arg.fn
  self.delta_callbacks[arg.ring] = arg.fn
end

function ArcService:clear_ring(r)
  for i=1, self.CONFIG.RING_STEPS do
    self.arc:led(r, i, 0)
  end
end

function ArcService:display_sequence(arg)
  local r = arg.ring
  local seq = arg.seq
  local active = arg.active
  local offset = math.max(math.floor((self.CONFIG.RING_STEPS - #seq) / 2), 1)

  self:clear_ring(r)

  for i, step in ipairs(seq) do
    local brightness
    if i == active then
      brightness = self.CONFIG.BRIGHTNESS.ACTIVE
    else
      brightness = step == true and self.CONFIG.BRIGHTNESS.PULSE or self.CONFIG.BRIGHTNESS.STEP
    end
    self.arc:led(r, offset + i, brightness)
  end
end

function ArcService:display_cv(arg)
  local r = arg.ring
  local cv = arg.cv
  local cv_led_length = math.floor(cv * 8)
  local offset = math.max(math.ceil((self.CONFIG.RING_STEPS - cv_led_length) / 2), 1)

  self:clear_ring(r)

  --self.arc:segment(r, math.pi/offset, math.pi/math.floor(cv_led_length/2), 11)
  --self.arc:segment(r, 2, (2 * math.pi)/(cv_led_length / 64) / 2, 11)

  for i=1, cv_led_length do
    self.arc:led(r, offset + i, self.CONFIG.BRIGHTNESS.CV)
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

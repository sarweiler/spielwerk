er = require("er")

engine.name = "PolyPerc"

local a = arc.connect()
local beats = {}
local num_steps = 17
local current_step = 1

local update_ui,
      step_cb

a.delta = function(n,d)
  if (n == 1) then
    num_steps = num_steps + d
    beats = er.gen(math.max(0, math.min(num_steps, 64)), 64)
  end
  if (n == 2) then
    cutoff = params:get("cutoff") + d
    params:set("cutoff", cutoff)
  end
  update_ui()
end

arc_redraw = function()
  a:all(0)
  
  for i,v in ipairs(beats) do
    if(v) then
      a:led(1, i, 8)
    else
      a:led(1, i, 0)
    end
    if (i == current_step) then
      a:led(1, i, 15)
    end
  end
  
  a:segment(2, math.rad(180), params:get("cutoff")/100, 10)
  a:refresh()
end

update_ui = function()
  arc_redraw()
  redraw()
end

local function set_cutoff()
  engine.cutoff(params:get("cutoff"))
  update_ui()
end

-- display UI
function redraw()
  screen.clear()
  screen.move(0, 8)
  screen.level(15)
  screen.text(params:get("cutoff"))
  screen.level(7)
  screen.move(0, 16)
  screen.text("cutoff")
  
  screen.update()
end

step_cb = function()
  current_step = current_step + 1
  if (current_step > 64) then
    current_step = 1
  end
  if(beats[current_step]) then
    engine.hz(math.random(50,500))
  end
  update_ui()
end

function init()
  
  m = metro.init({
    time = 0.25,
    count = -1,
    event = step_cb
  })
  beats = er.gen(num_steps, 64)
  
  params:add_control("cutoff", "cutoff", controlspec.new(50, 5000, "exp", 0, 1000, "hz"))
  params:set_action("cutoff", set_cutoff)
  params:set("cutoff", 1000)
  
  m:start()
  update_ui()
end
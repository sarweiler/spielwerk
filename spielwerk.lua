-- spielwerk: 3 rhythms, 1 cv
-- 1.0.0 @sbaio
-- http://llllllll.co/
--
-- ENC 1: select menu item
-- ENC 2: set number of pulses
-- ENC 3: set number of steps
-- hold KEY 1 + ENC 1: set bpm

local er = require("er")
local menu_items = include("lib/src/norns/menu_items")
local par = include("lib/src/norns/parameters")

engine.name = "PolyPerc"

local update_ui

local norns_state = {
  keys = {
    key1_down = false,
    key2_down = false,
    key3_down = false
  }
}

local menu = {}

-- enc
function enc(n, delta)
  if n == 1 then
    if norns_state.keys.key1_down then
      if menu.active < 4 then
        par.callbacks.set_seq_bpm_delta(menu.active, delta)
      else
        par.callbacks.set_cv_bpm_delta(delta)
      end
    else
      menu.active = util.clamp(menu.active + delta, 1, #menu.items)
    end
  elseif n == 2 and menu.active < 4 then
    par.callbacks.set_seq_pulses_delta(menu.active, delta)
  elseif n == 3 and menu.active < 4  then
    par.callbacks.set_seq_steps_delta(menu.active, delta)
  end
  update_ui()
end


-- key
function key(n, pressed)
  if pressed == 1 then
    norns_state.keys["key" .. n .. "_down"] = true
  else
    norns_state.keys["key" .. n .. "_down"] = false
  end
end


-- display UI
update_ui = function()
  menu_items.update(menu)
  redraw()
end

function redraw()
  screen.clear()
  for i, item in ipairs(menu.items) do
    screen.move(0, i * 8)
    if menu.active == i then
      screen.level(15)
    else
      screen.level(7)
    end
    screen.text(item.name)
    screen.move(128, i * 8)
    screen.text_right(item.value)
  end
  
  screen.update()
end


-- init
function init()
  menu.active = 1
  par.add_params(par.callbacks)
  update_ui()
end
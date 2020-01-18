local as = require("lib/src/arcservice")

describe("ArcService", function()
  local arc_stub

  setup(function()
    arc_stub = {
      connect = function() return {} end
    }
  end)

  it("should connect to arc", function()
    local connect_spy = spy.on(arc_stub, "connect")
    
    -- when:
    local a = as:new(arc_stub)

    -- then:
    assert.spy(connect_spy).was_called()
  end)

  it("should initialize a delta function", function()
    local a = as:new(arc_stub)

    -- expect:
    assert.is.equal("function", type(a.arc.delta))
  end)

  it("should set a delta function for a ring", function()
    local a = as:new(arc_stub)
    local ring_fn_spy = spy.new(function() end)

    a:set_delta_fn{
      ring=1,
      fn=ring_fn_spy
    }

    -- when:
    a.arc.delta(1, 42)
    
    -- then:
    assert.spy(ring_fn_spy).was_called_with(42)
  end)

end)

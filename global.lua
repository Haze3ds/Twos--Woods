
do -- Global Environment Manipulations

  -- deprecated module function, simply break it.
  module = nil

  -- For convienience, a callable null
  NULLFUNC = function() end

  -- Make unpack and table.unpack be the same function, regardless of version
  do
    if table.unpack then
      unpack = table.unpack
    else
      table.unpack = unpack
    end
  end

  -- table.pack taken from penlight
  if not table.pack then
    function table.pack (...)
      return { n = select('#',...); ... }
    end
  end

  -- logging facility only during testing
  if not __TESTING then print = NULLFUNC end

  -- debug infinite loop detection
  if __TESTING then
    local function timeout() error("Runaway script terminated.") end
    function RESET_DEBUG_HOOK()
      debug.sethook()
      debug.sethook(timeout, "", 100000000)
    end
  else
    RESET_DEBUG_HOOK = NULLFUNC
  end

end


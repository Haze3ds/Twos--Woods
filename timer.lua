
local active_timers = setmetatable({}, {__mode = "k"})

local timer_metatable = {
  __index = {
    clock = 0,

    update = function(self, dt)
      self.clock = self.clock + dt
      if self.clock >= self.seconds then
        if self.style == "interval" then
          self:renew()
        else -- timeout
          self:cancel()
        end
        self.callback(self)
      end
      return self
    end,

    cancel = function(self)
      active_timers[self] = nil
      return self
    end,

    renew = function(self)
      active_timers[self] = true
      self.clock = math.max((self.clock or 0) - self.seconds, 0)
      return self
    end,
  }
}

local timer = {

  create_timeout = function(self, seconds, callback)
    return self:create_timer("timeout", seconds, callback)
  end,

  create_interval = function(self, seconds, callback)
    return self:create_timer("interval", seconds, callback)
  end,

  create_timer = function(self, style, seconds, callback)
    local t = setmetatable({
      style = style,
      callback = callback,
      seconds = seconds,
    }, timer_metatable)
    t:renew()
    return t
  end,

  update_timers = function(self, dt)
    for t, _ in pairs(active_timers) do
      t:update(dt)
    end
  end
}

return timer


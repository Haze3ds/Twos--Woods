-- input manager singleton
local unpack = unpack or table.unpack
local SINE_PART = 0.707106781

local keycheck do
  local mt = {
    __index = function(self, key)
      return rawget(self, 'tbl')[key] or rawget(self, 'def')
    end
  }
  keycheck = function(tbl, default)
    return setmetatable({tbl=tbl, def=default}, mt)
  end
end

local input
input = {

  _press = {},
  _newpress = {},
  _tap = {},
  _hold = {},
  _axis = {},
  _textqueue = {},
  _currenttext = {},
  lastKey = false,

  scheme = {
    keyboard = {
      [" "] = { "jump", "menu_enter" },
      up  = {"up", "menu_up", "text_up"},
      down = {"down", "menu_down", "text_down"},
      left = {"left", "menu_left", "text_left"},
      right = {"right", "menu_right", "text_right"},
      start = {"menu_enter"},
      x = {"menu_enter"},
      cpadup = {"up", "menu_up"},
      cpadleft = {"left", "menu_left"},
      cpaddown = {"down", "menu_down"},
      cpadright = {"right", "menu_right"},
      z = {"jump"},
      x = {"jump"},
      c = {"jump"},
      pause = {"pause"},
      pageup = {"menu_pageup"},
      pagedown = {"menu_pagedown"},
      home = {"menu_home"},
      ["end"] = {"menu_end"},
      escape = {"menu_escape"},
      backspace = {"text_backspace"},
      delete = {"text_delete"},
      f1 = {"help"},
      f2 = {"screenshot"},
      f3 = {"debug_info"},
      f5 = {"changescale"},
      f8 = {"debug_garbage"},
      f9 = {"debug_reset"},
      f10 = {"debug_terminate"},
      f11 = {"fullscreen"},
    },
    gamepad = {
      axis = {
        leftx = {
          negative = { "left", "menu_left", threshold = -0.5, },
          positive = { "right", "menu_right", threshold = 0.5, },
        },
        lefty = {
          negative = { "up", "menu_up", threshold = -0.5, },
          positive = { "down", "menu_down", threshold = 0.5, },
        },
        rightx = {
          negative = { "left", "menu_left", threshold = 0.25, },
          positive = { "right", "menu_right", threshold = 0.75, },
        },
        righty = {
          negative = { "up", "menu_up", threshold = 0.25, },
          positive = { "down", "menu_down", threshold = 0.75, },
        },
      },
      button = {
        dpup = {"up", "menu_up"},
        dpdown = {"down", "menu_down"},
        dpleft = {"left", "menu_left"},
        dpright = {"right", "menu_right"},
        a = {"jump", "menu_enter"},
        b = {"jump", "menu_escape"},
        x = {"jump"},
        y = {"jump"},
        leftshoulder = {"menu_pageup"},
        rightshoulder = {"menu_pagedown"},
        lefttrigger = {"menu_home"},
        righttrigger = {"menu_end"},
        back = {"menu_escape"},
        start = {"pause"},
      }
    },
  },

  reset = function(self)
    --love.keyboard.setKeyRepeat(0.500, 0.08)
    for k, _ in pairs(self._press) do self._press[k] = nil end
    for k, _ in pairs(self._newpress) do self._press[k] = nil end
    for k, _ in pairs(self._tap) do self._tap[k] = nil end
    for k, _ in pairs(self._hold) do self._hold[k] = nil end
    for i = 1, #self._textqueue do self._textqueue[i] = nil end
    for i = 1, #self._currenttext do self._currenttext[i] = nil end
    self.lastKey = false
  end,

  update = function(self, dt)
    for id, _ in pairs(self._tap) do
      self._tap[id] = nil
    end
    for id, _ in pairs(self._newpress) do
      self._tap[id] = true
      self._newpress[id] = nil
    end
    for id, value in pairs(self._hold) do
      self._hold[id] = value + dt
    end

    -- swap current and previous text queues, and clear for new keyspresses
    self._currenttext, self._textqueue = self._textqueue, self._currenttext
    for i = 1, #self._textqueue do self._textqueue[i] = nil end
    self.lastKey = self._currenttext[1] or false
  end,

  circle_movement = function(self)
    local dx, dy = 0, 0
    if self._hold.up then dy = -1 end
    if self._hold.down then dy = 1 end
    if self._hold.left then dx = -1 end
    if self._hold.right then dx = 1 end

    if (dx ~= 0) and (dy ~= 0) then
      dx, dy = dx*SINE_PART, dy*SINE_PART
    end

    return dx, dy
  end,

  buttonpressed = function(self, bindings, repeating)
    for _, key in ipairs(bindings) do
      self._newpress[key] = true
      self._hold[key] = self._hold[key] or 0
      if not repeating then
        self._press[key] = (self._press[key] or 0) + 1
      end
    end
  end,

  buttonreleased = function(self, bindings)
    for _, key in ipairs(bindings) do
      local ref = self._press[key]
      if ref then
        ref = ref - 1
        if ref > 0 then
          self._press[key] = ref
        else
          self._press[key] = nil
          self._hold[key] = nil
        end
      end
    end
  end,

  textinput = function(self, u)
    self._textqueue[#self._textqueue+1] = u
  end,

  keypressed = function(self, key, repeating)
    local bindings = self.scheme.keyboard[key]
    if bindings then self:buttonpressed(bindings, repeating) end
  end,

  keyreleased = function(self, key)
    local bindings = self.scheme.keyboard[key]
    if bindings then self:buttonreleased(bindings) end
  end,

  gamepadpressed = function(self, joystick, button)
    local bindings = self.scheme.gamepad.button[button]
    if bindings then self:buttonpressed(bindings) end
  end,

  gamepadreleased = function(self, joystick, button)
    local bindings = self.scheme.gamepad.button[button]
    if bindings then self:buttonreleased(bindings) end
  end,

  gamepadaxis = function(self, joystick, axis, value)
    local binding = self.scheme.gamepad.axis[axis]
    if binding then
      local last_axis = self._axis[axis] or 0
      if binding.negative then
        if last_axis > binding.negative.threshold and value <= binding.negative.threshold then
          self:buttonpressed(binding.negative)
        elseif last_axis <= binding.negative.threshold and value > binding.negative.threshold then
          self:buttonreleased(binding.negative)
        end
      end
      if binding.positive then
        if last_axis < binding.positive.threshold and value >= binding.positive.threshold then
          self:buttonpressed(binding.positive)
        elseif last_axis >= binding.positive.threshold and value < binding.positive.threshold then
          self:buttonreleased(binding.positive)
        end
      end
      self._axis[axis] = value
    end
  end,
}

input.tap = keycheck(input._tap)
input.hold = keycheck(input._hold)
input.holdlen = keycheck(input._hold, 0)

return input


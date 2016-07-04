
local unpack = unpack or table.unpack

local function raw_overlaps(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
  return not ((ax1 >= bx2) or (bx1 >= ax2) or (ay1 >= by2) or (by1 >= ay2))
end

local rectangle = {

  create = function(self, obj)
    return setmetatable(obj or {}, self)
  end,

  __index = {

    x = 0,
    y = 0,
    w = 0,
    h = 0,

    rectangle_valid = function(self)
      return (self.w > 0) and (self.h > 0)
    end,

    rectangle = function(self, xo, y, w, h)
      if xo == nil then return self.x, self.y, self.w, self.h end
      if type(xo)=="table" then
        self.x, self.y, self.w, self.h = xo.x, xo.y, xo.w, xo.h
      else
        self.x, self.y, self.w, self.h = x, y, w, h
      end
      return self
    end,

    left = function(self, x)
      if x == nil then return self.x else self.x = x end
      return self
    end,

    top = function(self, y)
      if y == nil then return self.y else self.y = y end
      return self
    end,

    width = function(self, w)
      if w == nil then return self.w else self.w = w end
      return self
    end,

    height = function(self, h)
      if h == nil then return self.h else self.h = h end
      return self
    end,

    right = function(self, x)
      if x == nil then return self.x + self.w else self.w = x - self.x end
      return self
    end,

    bottom = function(self, y)
      if y == nil then return self.y + self.h else self.h = y - self.h end
      return self
    end,

    center_x = function(self, x)
      if x == nil then return self.x + self.w*0.5 else self.x = x - self.w*0.5 end
      return self
    end,

    center_y = function(self, y)
      if y == nil then return self.y + self.h*0.5 else self.y = y - self.h*0.5 end
      return self
    end,

    overlaps_rectangle = function(self, xother, y, w, h)
      local ax1, ay1 = self.x, self.y
      local ax2, ay2 = ax1 + self.w, ay1 + self.h
      local bx1, bx2, by1, by2
      if type(xother)=="table" then
        bx1, by1 = xother.x, xother.y
        bx2, by2 = bx1 + xother.w, by1 + xother.h
      else
        bx1, by1 = xother, y
        bx2, by2 = bx1 + w, by1 + h
      end
      return raw_overlaps(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
    end,

    contains_point = function(self, xother, y)
      local ax1, ay1 = self.x, self.y
      local ax2, ay2 = ax1 + self.w, ay1 + self.h
      local x
      if type(xother)=="table" then x, y = xother.x, xother.y else x = xother end
      return raw_overlaps(ax1, ay1, ax2, ay2, x, y, x, y)
    end,

    move_rectangle = function(self, dx, dy)
      self.x = self.x + dx
      self.y = self.y + dy
      return self
    end,

    rectangle_bounds = function(self, x, y, w, h)
      if x == nil then
        return self:left(), self:top(), self:right(), self:bottom()
      else
        return self:left(x):top(y):right(w):bottom(h)
      end
    end,

    rectangle_size = function(self, w, h)
      if w == nil then return self:width(), self:height() end
      return self:width(w):height(h)
    end,
  },
}

-- Composite accessors take/return two parameters, x and y for each of the
-- 9 possible control points for the rectangle.
for _, accessor in ipairs {
--  method            x-accessor  y-accessor  alias
  { "top_left",       "left",     "top",      "left_top"      },
  { "top_center",     "center_x", "top",      "center_top"    },
  { "top_right",      "right",    "top",      "right_top"     },
  { "center_left",    "left",     "center_y", "left_center"   },
  { "center",         "center_x", "center_y", }, -- no alias for "center"
  { "center_right",   "right",    "center_y", "right_center"  },
  { "bottom_left",    "left",     "bottom",   "left_bottom"   },
  { "bottom_center",  "center_y", "bottom",   "center_bottom" },
  { "bottom_right",   "right",    "bottom",   "right_bottom"  },
} do
  local method, left, right, alias = unpack(accessor)
  local fn = function(self, x, y)
    if x == nil then
      return self[left](self), self[right](self)
    else
      return self[left](self, x)[right](self, y)
    end
  end
  rectangle.__index[method] = fn
  if alias then
    rectangle.__index[alias] = fn
  end
end

setmetatable(rectangle, {
  __call = function(_, ...) return rectangle:create(...) end
})

return rectangle


-- Object Prototype
--
local observer = require 'observer'

local extend = function(obj, ...)
  for i = 1, select('#',...) do
    for k, v in pairs(select(i, ...)) do
      obj[k] = v
    end
  end
  return obj
end

local generic_metatable = {
  __call = function(parent, ...)
    return parent:clone(...)
  end,
}

local metatables = setmetatable({}, {
  __mode = "k",
  __index = function(self, key)
    local mt = extend({__index = key}, generic_metatable)
    rawset(self, key, mt)
    return mt
  end,
})

-- child = parent:clone { additional_keys = additional_values }
local clone = function(parent, ...)
  local child = setmetatable({}, metatables[parent])
  if select('#', ...) > 0 then extend(child, ...) end
  local init = rawget(parent, "_init")
  if init ~= nil then
    init(child, parent)
  end
  return child
end

-- self:bind(self.method)
local bind = function(obj, func)
  return function(...) return func(obj, ...) end
end

-- class:super()  or  class:super('method', self)
local super = function(parent, method, self, ...)
  local grandparent = getmetatable(parent).__index
  if method == nil then
    return grandparent
  else
    return grandparent[method](self, ...)
  end
end

local object = setmetatable({
  clone = clone,
  bind = bind,
  super = super,
  extend = extend,
  include = extend,
  on = observer.on,
  off = observer.off,
  send = observer.send,
}, generic_metatable)

return object


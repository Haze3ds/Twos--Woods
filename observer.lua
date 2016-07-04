-- Observer Pattern

local handlers = setmetatable({}, {
  __mode = "k",
  __index = function(self, key)
    local H = {}
    rawset(self, key, H)
    return H
  end
})

local observer = {
  on = function(context, message, ...)
    local H = handlers[context]
    local M = H[message] or {}
    for i = 1, select('#', ...) do
      table.insert(M, select(i,...))
    end
    H[message] = M
    return context
  end,

  send = function(context, message, ...)
    local H = handlers[context]
    local M = H[message]
    if M then
      local cache = {}
      for i = 1, #M do cache[i] = M[i] end
      for i = 1, #cache do cache[i](...) end
    end
    return context
  end,

  off = function(context, message, ...)
    local H = handlers[context]
    if message == nil then
      for k, _ in pairs(H) do H[k] = nil end
    elseif (H[message] ~= nil) then
      local N = select('#', ...)
      if N == 0 then
        H[message] = nil
      else
        local M = H[message]
        for k = #M, 1, -1 do
          for i = 1, N do
            if M[i] == select(i,...) then
              table.remove(M, k)
              break
            end
          end
        end
      end
    end
    return context
  end,
}

return observer


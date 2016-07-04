-- Color flyweights

local color
local unpack = unpack or table.unpack

local function clamp(x, min, max)
  if x < min then return min end
  if x > max then return max end
  return x
end

local function hsl2rgb(hue, sat, lit)
  hue = clamp(hue or 360, 0, 360)
  sat = clamp(sat or 1, 0, 1)
  lit = clamp(lit or 1, 0, 1)
  local chroma = (1 - math.abs(2*lit - 1)) * sat
  local h = hue / 60
  local x = (1 - math.abs(h%2 -1)) * chroma
  local r, g, b
  if h < 1 then     r, g, b = chroma, x, 0
  elseif h < 2 then r, g, b = x, chroma, 0
  elseif h < 3 then r, g, b = 0, chroma, x
  elseif h < 4 then r, g, b = 0, x, chroma
  elseif h < 5 then r, g, b = x, 0, chroma
  else              r, g, b = chroma, 0, x end
  local m = lit - chroma/2
  return (r+m)*255, (g+m)*255, (b+m)*255
end

local function rgb2hsl(r, g, b)
  r = clamp(r or 255, 0, 255) / 255.0
  g = clamp(g or 255, 0, 255) / 255.0
  b = clamp(b or 255, 0, 255) / 255.0
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local lit = (max + min) / 2
  local hue, sat = 0, 0
  if max ~= min then
    local d = max - min
    sat = (max - min) / ((sat > 0.5) and (2 - max - min) or (max + min))
    local maxhalf = max / 2
    local dr = (((max-r) / 6) + maxhalf) / max
    local dg = (((max-g) / 6) + maxhalf) / max
    local db = (((max-b) / 6) + maxhalf) / max
    if max == r then hue = db + dg
    elseif max == g then hue = (1/3) + dr - db
    else hue = (2/3) + dg - dr end
    while hue < 0 do hue = hue + 1 end
    while hue > 1 do hue = hue - 1 end
  end
  return hue * 360, sat, lit
end

local cache = {}
local function makecolor(r, g, b, a)
  r = clamp(r or 255, 0, 255)
  g = clamp(g or 255, 0, 255)
  b = clamp(b or 255, 0, 255)
  a = clamp(a or 255, 0, 255)
  local s = string.format("#%02X%02X%02X%02X", r, g, b, a)
  local c = cache[s]
  if c == nil then
    c = setmetatable({ r, g, b, a }, color)
    cache[s] = c
  end
  return c
end

color = setmetatable({

  hsl = function(hue, sat, lit, alpha)
    local r, g, b = hsl2rgb(hue, sat, lit)
    return makecolor(r, g, b, alpha)
  end,

  __index = {
    255, 255, 255, 255,

    red = function(self, v)
      if v == nil then return self[1] end
      return makecolor(v, self[2], self[3], self[4])
    end,

    green = function(self, v)
      if v == nil then return self[2] end
      return makecolor(self[1], v, self[3], self[4])
    end,

    blue = function(self, v)
      if v == nil then return self[3] end
      return makecolor(self[1], self[2], v, self[4])
    end,

    alpha = function(self, v)
      if v == nil then return self[4] end
      return makecolor(self[1], self[2], self[3], v)
    end,

    rgb = function(self, r, g, b)
      if r == nil then return self[1], self[2], self[3] end
      return makecolor(r, g, b, self[4])
    end,

    rgba = function(self, r, g, b, a)
      if r == nil then return self[1], self[2], self[3], self[4] end
      return makecolor(r, g, b, a)
    end,

    hsl = function(self, h, s, l)
      if h == nil then return rgb2hsl(self[1], self[2], self[3]) end
      return color.hsl(h, s, l, self[4])
    end,

    hue = function(self, v)
      local h, s, l = rgb2hsl(self[1], self[2], self[3])
      if v == nil then return h end
      return color.hsl(v, s, l)
    end,

    saturation = function(self, v)
      local h, s, l = rgb2hsl(self[1], self[2], self[3])
      if v == nil then return s end
      return color.hsl(h, v, l)
    end,

    lightness = function(self, v)
      local h, s, l = rgb2hsl(self[1], self[2], self[3])
      if v == nil then return l end
      return color.hsl(h, s, v)
    end,
  }
}, {
  __call = function(self, r, g, b, a)
    return makecolor(r, b, g, a)
  end,
})


for _, row in ipairs {
  { "BLACK",       0,   0,   0, },
  { "BLUE",        0,   0, 255, },
  { "BROWN",     170,  85,   0, },
  { "CYAN",        0, 255, 255, },
  { "GRAY",       85,  85,  85, },
  { "GREEN",       0, 255,   0, },
  { "MAGENTA",   255,   0, 255, },
  { "MAROON",    170,   0,   0, },
  { "MIDNIGHT",    0,   0,  85, },
  { "NAVY",        0,   0, 170, },
  { "OLIVE",     170, 170,   0, },
  { "ORANGE",    255, 170,   0, },
  { "ORANGERED", 255,  85,   0, },
  { "PURPLE",    170,   0, 170, },
  { "RED",       255,   0,   0, },
  { "SILVER",    170, 170, 170, },
  { "TEAL",        0, 170, 170, },
  { "WHITE",     255, 255, 255, },
  { "YELLOW",    255, 255,   0, },
  { "PUREWHITE", 255, 255, 255, },
  { "PUREBLACK",   0,   0,   0, },
  { "ALPHA100",    0,   0,   0, 255, },
  { "ALPHA75",     0,   0,   0, 192, },
  { "ALPHA50",     0,   0,   0, 128, },
  { "ALPHA25",     0,   0,   0,  64, },
  { "ALPHA0",      0,   0,   0,   0, },
} do
  local n, r, g, b, a = unpack(row)
  color[n] = color(r, g, b, a)
end

return color


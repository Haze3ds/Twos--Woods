-- graphics manager
love.graphics.setScreen('top')
local object = require 'object'
local color = require 'color'

 
local fontset = [=[ !"#$%&'()*+,-./0123456789:;<=>?]=] ..
  [=[@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_]=] ..
  [=[`abcdefghijklmnopqrstuvwxyz{|}~]=]

local graphics
graphics = object {
  gameWidth = 240,
  gameHeight = 160,
  xScale = 1,
  yScale = 1,
  xTranslate = 0,
  yTranslate = 0,
  defaultMaxScale = 3,
  mouseVisible = false,  
  font = false,
  fontHeight = 0,
 lastColor = false,

  init = function(self)
    self.xScale = math.max(1,math.floor(love.graphics.getWidth()/self.gameWidth))
    self.yScale = math.max(1,math.floor(love.graphics.getHeight()/self.gameHeight))
    --love.mouse.setVisible(self.mouseVisible)
    self:load_font("cgafont.png")
    return self
  end,

  start = function(self)
    --love.graphics.setScissor(self.xTranslate, self.yTranslate,
       -- self.gameWidth * self.xScale, self.gameHeight * self.yScale)
    love.graphics.translate(self.xTranslate, self.yTranslate)
    --love.graphics.scale(self.xScale, self.yScale)
    love.graphics.setLineWidth(1)
    --love.graphics.setLineStyle("rough")
    self:set_color(color.PUREBLACK)
    return self
  end,

  stop = function(self)
    --love.graphics.setScissor()
    return self
  end,

  determine_maxscale = function(self)
    local _, _, flags = love.window.getMode()
    local w, h = love.window.getDesktopDimensions(flags.display)
    local x, y = math.floor(w/self.gameWidth), math.floor(h/self.gameHeight)
    return math.max(self.defaultMaxScale, math.min(x, y))
  end,

  next_scale = function(self)
    if not love.window.getFullscreen() then
      self:set_scale((self.xScale%(self:determine_maxscale()))+1)
    end
    return self
  end,

  set_scale = function(self, size)
    if not love.window.getFullscreen() then
      love.window.setMode(self.gameWidth*size, self.gameHeight*size, { resizable = true })
      self:recompute_matrix()
      love.mouse.setVisible(self.mouseVisible)
    end
    return self
  end,

  recompute_matrix = function(self)
    local width, height, flags = love.window.getMode()
    local size = math.min(math.floor(width/self.gameWidth), math.floor(height/self.gameHeight))
    self.xScale, self.yScale = size, size
    self.xTranslate = math.floor((width - self.gameWidth * size) * 0.5)
    self.yTranslate = math.floor((height - self.gameHeight * size) * 0.5)
    return self
  end,

  on_resize = function(self, width, height)
    self:recompute_matrix()
  end,

  toggle_fullscreen = function(self)
    love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    self:recompute_matrix()
    love.mouse.setVisible(self.mouseVisible)
    return self
  end,

  toggle_mouse = function(self, val)
    if val == nil then
      self.mouseVisible = not self.mouseVisible
    else
      self.mouseVisible = val
    end
    love.mouse.setVisible(self.mouseVisible)
    return self
  end,

  save_screenshot = function(self)
    local name = string.format("screenshot-%s.png", os.date("%Y%m%d-%H%M%S"))
    local shot = love.graphics.newScreenshot()
    shot:encode(name, "png")
    return self
  end,

  load_font = function(self, name)
    self.fontimg = love.graphics.newImage(name)
    --self.fontimg:setFilter("nearest", "nearest")
    --self.fontHeight = self.fontimg:getHeight()
    --self.font = love.graphics.newImageFont(self.fontimg, fontset)
    --self.font:setLineHeight(self.fontHeight)
    --love.graphics.setFont(self.font)
    --return self
  end,

  write = function(self, x, y, str, ...)
    if select('#',...) > 0 then
      str = str:format(...)
    end
    if y == "center" then
      local lines = 0
      for _ in str:gmatch("[^\r\n]+") do lines = lines + 1 end
      y = math.floor((self.gameHeight-(self.fontHeight+2)*lines)/2)
    end
    for line in str:gmatch("[^\r\n]+") do
      local lx = x 
      if lx == "center" then
        lx = math.floor((self.gameWidth - (self.fontHeight+2)))
      end
      love.graphics.print(line, lx, y)
      y = y + self.fontHeight + 2
    end
    return self
  end,

  draw_rect = function(self, x, y, w, h, lined)
    love.graphics.rectangle(lined or "fill", math.floor(x), math.floor(y), math.floor(w), math.floor(h))
    return self
  end,

  set_color = function(self, r, g, b, a)
    if type(r)=="table" then
      if self.lastColor ~= r then
        self.lastColor = r
        --love.graphics.setColor(r)
      end
    else
      self.lastColor = nil
      if a then
        love.graphics.setColor(r, g, b, a)
      else
        love.graphics.setColor(r, g, b)
      end
    end
    return self
  end,
}

return graphics


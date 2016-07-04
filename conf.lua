
function love.conf(t)
  t.title = "UnNamed"
  t.author = "Matt Haze 2048 Clone by Inny"
  t.version = "0.9.0"
  t.identity = nil
  t.release = true
  t.console = true

  t.window.width = 720
  t.window.height = 480
  t.window.minwidth = 240
  t.window.minheight = 160
  t.window.resizable = true
  t.window.fullscreen = false
  t.window.vsync = true
  t.window.fsaa = 0

  t.modules.audio = true
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = true
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = false
  t.modules.sound = true
  t.modules.system = true
  t.modules.timer = true
  t.modules.window = true
end


__TESTING = false
require("AnAL")
require("3ds")
require 'global'
local observer = require 'observer'
local object = require 'object'
local timer = require 'timer'
local input = require 'input'
local color = require 'color'
local graphics = require 'graphics'
local rectangle = require 'rectangle'

-- Enables 3D mode.
	love.graphics.set3D(true)

------Enemies Dropping
-- Enemy timer
createBombTimerMax = 18
createBombTimer = createBombTimerMax

--Countdown Timer
totalTime = 160

--Score // Use/ score = score + 10 to increase
score = 0

--Player Table

Player = { x = 75, y = 175, speed = 20, sprite = nil, HP = 10, y_velocity = 0}
isAlive =  false
--score = 0
gravity = 400
jump_height = 174

Player.state = 'Reset'
Player.state = 'Explosion2'	
Player.state = 'Explosion'
Player.state = 'Normal2'
Player.state ='Normal3'
Player.state ='Normal'

bombies = {}
bombSprite = nil

--Dont use anymore for falling enemies
enemies = {}
enemySprite = nil

--Bomb Table
Bomb = { x = 126, y = 177, speed = 20, sprite = nil, HP = 2}
isAlive = false
gravity = 400
jump_height = 174

--Enemy Table 
Enemy = { x = 160, y = 177, speed = 20, sprite = nil, HP = 2}
isAlive = false
gravity = 400
jump_height = 174
Enemy.state = 'Dropped'

--Enemy2 Table (Same Enemy as first)
Enemy2 = { x = 110, y = 177, speed = 20, sprite = nil, HP = 2}
isAlive = false

--EnemyB Table (White Enemy)
EnemyB = { x = 50, y = 177, speed = 20, sprite = nil, HP = 2}
isAlive = false

--EnemyB2 Table (Same as White Enemy)
EnemyB2 = { x = 200, y = 177, speed = 20, sprite = nil, HP = 2}
isAlive = false

--EnemyStack
EnemyStack = { x = 199, y = 160, speed = 20, sprite = nil, HP = 2}

--WhiteEnemyStack
WhiteEnemyStack = { x = 300, y = -100, speed = 20, sprite = nil, HP = 2}


--EnemyStack
PlacedStack = { x = 199, y = 160, speed = 20, sprite = nil, HP = 2}

--Enemy3Stack
Enemy3Stack = { x = 199, y = 160, speed = 20, sprite = nil, HP = 2}



random = math.random
--BGM = love.audio.newSource("BGM.wav", "static")
Player.sprite = love.graphics.newImage('Player.png')
Bomb.sprite = love.graphics.newImage('Bomb.png')
Enemy.sprite = love.graphics.newImage('Enemy.png')
enemySprite = love.graphics.newImage('Enemy.png')
Enemy2.sprite = love.graphics.newImage('Enemy.png')
EnemyB.sprite = love.graphics.newImage('EnemyB.png')
EnemyB2.sprite = love.graphics.newImage('EnemyB.png')
WhiteEnemyStack.sprite = love.graphics.newImage('WhiteEnemyStack.png')
EnemyStack.sprite = love.graphics.newImage('EnemyStack.png')
PlacedStack.sprite = love.graphics.newImage('PlacedStack.png')
Enemy3Stack.sprite = love.graphics.newImage('Enemy3Stack.png')
PlayerRight = love.graphics.newImage('PlayerRight.png')
Background = love.graphics.newImage('Background.png')
BottomBG = love.graphics.newImage('BottomBG.png')
StartMenu = love.graphics.newImage('StartMenu.png')
 --BackGroundAnimation
 local img  = love.graphics.newImage("Backani.png")
   -- Create animation.
   anim = newAnimation(img, 400, 240, 0.4, 0)
   
   --PlayerRightAnimation
 local img2  = love.graphics.newImage("PlayerAnimRight.png")
   -- Create animation.
   PlayerRightAnim = newAnimation(img2, 16, 19, 0.2, 0)
    --PlayerLeftAnimation
 local img3  = love.graphics.newImage("PlayerAnimLeft.png")
   -- Create animation.
   PlayerLeftAnim = newAnimation(img3, 16, 19, 0.2, 0)
    --BombexplosionAnimation
 local img4  = love.graphics.newImage("BombAnim48.png")
   -- Create animation.
   BombAnim = newAnimation(img4, 100, 55, 2, 2)
 --BombAnim:setDelay ( 1, 4)
  --BombAnim:setDelay ( 2, 700)
  BombAnim:setMode("once")
  
  
util = {
  lerp = function(y1, y2, x)
    return y1 + (x * (y2 - y1))
  end,
  sign = function(x)
    if x > 0 then return 1 elseif x < 0 then return -1 else return 0 end
  end,
}

image_component = {
  load_image = function(self, name)
    self._image = love.graphics.newImage(name)
    --self._image:setFilter("nearest", "nearest")
   
  end,

  draw_image = function(self, x, y)
  
    love.graphics.draw(self._image, x, y)
	
  end,
  

  image_width = function(self) return self._image:getWidth() end,
  image_height = function(self) return self._image:getHeight() end,
}

slide_component = {
  speed = 2.5,

  slide_init = function(self)
    self:on("update", self:bind(self.slide_update))
    self.slide_info = {}
  end,

  slide_to = function(self, x, y, speed)
    print ("slide to", x, y)
    self.slide_info.active = true
    self.slide_info.speed = speed or self.speed
    self.slide_info.to_x = x
    self.slide_info.to_y = y
    local x, y = self:tile_position()
    self.slide_info.from_x = x
    self.slide_info.from_y = y
    self.slide_info.frame = 0
  end,

  slide_update = function(self, dt)
    if self.slide_info.active then
      local info = self.slide_info
      info.frame = math.min(1, info.frame + (info.speed * dt))
      local x, y
      x = util.lerp(info.from_x, info.to_x, info.frame)
      y = util.lerp(info.from_y, info.to_y, info.frame)
      self:tile_position(x, y)
      if info.frame == 1 then
        info.active = false
      end
    end
  end,

  slide_active = function(self)
    return self.slide_info.active
  end,

  slide_target = function(self)
    if self.slide_info.active then
      return self.slide_info.to_x, self.slide_info.to_y
    else
      return self:tile_position()
    end
  end,
}

tile = object(slide_component, image_component, {
  tile_value = 2,
  tile_merged_with = nil,
  tile_width = 32,
  tile_height = 32,

  _init = function(self)
    self.rect = rectangle {
      w = tile_width,
      h = tile_height,
    }
    self:load_image("tile.png")
    self:slide_init()
    self:on("draw", self:bind(self.tile_draw))
  end,

  tile_position = function(self, x, y)
    if x == nil then return self.rect:left_top() end
    self.rect:left_top(x, y)
  end,

  tile_draw = function(self, offset_x, offset_y)
  love.graphics.setDepth(3)
    local x, y, w, h = self.rect:rectangle()
    local text = tostring(self.tile_value)
    local centering = text:len() * 4
    graphics:set_color(color.PUREBLACK)
    self:draw_image(offset_x + x, offset_y + y)
    graphics:set_color(color.PUREBLACK)
    graphics:write(offset_x + x + 17 - centering, offset_y + y+12, text)
  end,
})


array2d = {
  create = function(class, w, h)
    local self = setmetatable({}, class)
    self.w = w
    self.h = h
    return self
  end,

  __index = {
    get = function(self, x, y)
      local pos = 1 + (y-1)*self.w + (x-1)
      return self[pos]
    end,

    set = function(self, x, y, v)
      local pos = 1 + (y-1)*self.w + (x-1)
      self[pos] = v
    end,

    clone = function(self)
      local copy = setmetatable({}, getmetatable(self))
      for k, v in pairs(self) do copy[k] = v end
      return copy
    end
  },
}

grid_funcs = {
  merge = function(grid, sx, sy, ex, ey, dx, dy)
    local x_step, y_step = util.sign(ex - sx), util.sign(ey - sy)
    for y = sy, ey, y_step do
      for x = sx, ex, x_step do
        local tile = grid:get(x, y)
        if tile then
          local other = grid:get(x+dx, y+dy)
          if other and (tile.tile_value == other.tile_value) then
            grid:set(x, y, nil)
            tile.tile_merged_with = other
          end
        end
      end
    end
	
  end,

  compress = function(grid, sx, sy, ex, ey, dx, dy, repetitions)
    local x_step, y_step = util.sign(ex - sx), util.sign(ey - sy)
    for r = 1, repetitions do
      for y = sy, ey, y_step do
        for x = sx, ex, x_step do
          local tile = grid:get(x, y)
          if tile then
            local other = grid:get(x+dx, y+dy)
            if not other then
              grid:set(x+dx, y+dy, tile)
              grid:set(x, y, nil)
            end
          end
        end
      end
    end
  end,

  move = function(grid, direction)
    local newgrid = grid:clone()
    local sx, sy = 1, 1
    local ex, ey = newgrid.w, newgrid.h
    local dx, dy = 0, 0
    local reps = newgrid.h-2+1

    if direction == "up" then
      sy, dy = 2, -1
    elseif direction == "down" then
      sy, ey, dy = ey - 1, sy, 1
    elseif direction == "left" then
      sx, dx = 2, -1
    elseif direction == "right" then
      sx, ex, dx = ex - 1, sx, 1
    end

    grid_funcs.compress(newgrid, sx, sy, ex, ey, dx, dy, reps)
    grid_funcs.merge(newgrid, sx, sy, ex, ey, dx, dy)
    grid_funcs.compress(newgrid, sx, sy, ex, ey, dx, dy, reps)
    return newgrid
  end,
}

game_controls = {
  controls_init = function(self)
    self:on("update", self:bind(self.game_update))
  end,

  game_update = function(self, dt)
    if self.active_mode == "input" then
      if input.tap.up then self:move("up") end
      if input.tap.down then self:move("down") end
      if input.tap.left then self:move("left") end
      if input.tap.right then self:move("right") end
    end
	  
  end,
}

grid_component = {

  grid_rows = 4,
  grid_colums = 4,

  grid_init = function(self)
    self.tile_grid = array2d:create(self.grid_colums, self.grid_rows)
    self.tile_set = {}
    self.active_mode = "input"
    self:on("draw", self:bind(self.grid_draw))
    self:on("update", self:bind(self.grid_update))
  end,

  add_tile = function(self, tile, x, y)
    self.tile_set[tile] = true
  end,

  randomly_add_tile = function(self, tile)
    local c, tx, ty = 1
    for y = 1, self.grid_rows do
      for x = 1, self.grid_colums do
        if self.tile_grid:get(x, y) == nil then
          if (c == 1) or (random(1, c) == 1) then
            tx, ty = x, y
          end
          c = c + 1
        end
      end
    end
    if c == 1 then
      return "gameover"
    end

    tile:tile_position((tx-1)*tile.tile_width, (ty-1)*tile.tile_height)
    self.tile_set[tile] = true
    self.tile_grid:set(tx, ty, tile)
    return "play"
  end,

  grid_update = function(self, dt)
     anim:update(dt)
	 PlayerRightAnim:update(dt)
	 PlayerLeftAnim:update(dt)
	 --love.audio.play(BGM)
	 
	 --Countdown Timer
	 totalTime = totalTime - dt
	 
	 --Player Movement
  if love.keyboard.isDown("cpadleft")  then
     Player.x = Player.x - (Player.speed*dt)
    elseif love.keyboard.isDown("cpadright")  then
     Player.x = Player.x + Player.speed*dt
	 elseif love.keyboard.isDown("cpadup") then
     --Player.y = Player.y - Player.speed*dt
	 elseif love.keyboard.isDown("a") then
      if Player.y_velocity == 0 then -- We're probably on the ground, let's jump
      Player.y_velocity = jump_height
    end
   end
   --------2nd Bomb Drop and PLayer States
   
   if Player.state == 'Explosion'
   then
--   Bomb.x = math.random(50, love.graphics.getWidth() - 210 )
   --Bomb.y = Bomb.y + (15*dt)  
   BombAnim:update(dt)
   
   end
   
     if Player.state == 'Explosion2'
   then
--   Bomb.x = math.random(50, love.graphics.getWidth() - 210 )
   --Bomb.y = Bomb.y + (15*dt)  
   BombAnim:update(dt)
   
   end
   
   --if Bomb.y > 230 then
   --Player.state = 'Normal2'
   --end
   
   --if Player.state == 'Normal2' then
   --Bomb.y = Bomb.y - (2*dt)
   --Bomb.x = math.random(50, love.graphics.getWidth() - 210 ) 
   --end
   
   --if Player.state == 'Normal2' and Bomb.y < 177 then 
   --Player.state = 'Normal3'
   --Bomb.x = math.random(50, love.graphics.getWidth() - 210 )
   --Bomb.y = 177
   --end
   
   --if Player.state == 'Stack' then
   --EnemyStack.x = Enemy2.x
   --end
   
    --if Player.state == 'WhiteStack' then
   --WhiteEnemyStack.x = EnemyB2.x
   --end
   
   --if Player.state == 'FallStacker' then
  -- Enemy2.y = Enemy2.y - (15*dt)
--end
  -- 
   --if Player.state == '3Stack' then
   --Enemy3Stack.x = Enemy.x
   --end
   
 
   
  ---Enemies dropping
  -- Time out enemy creation
	createBombTimer = createBombTimer - (1*dt)
	if createBombTimer < 0 then
		createBombTimer = createBombTimerMax
			-- Create an enemy
		rand = math.random(50, love.graphics.getWidth() - 210 )
		newBomb = { x = rand, y = -10, sprite = Bomb.sprite }
    newBomb.canShoot = true
    newBomb.timer = 0
		table.insert(bombies, newBomb)
	end
	
   --Enemies dropping-- update the positions of enemies
	for i, Bomb in ipairs(bombies) do
		
	Bomb.y = Bomb.y + (15*dt) 
		
		
	 if Bomb.y > 177  then
			Bomb.y = Bomb.y - (15*dt)
			--Enemy = Enemy2
			--table.remove(enemies, i)
			--if score > 0 then
				--score = score - 50
			--end
	  end
	
		  	----Collision Player enemies----
		 if CheckCollision(Enemy.x , Enemy.y, Enemy.sprite:getWidth()  , Enemy.sprite:getHeight(), Player.x, Player.y , Player.sprite:getWidth(), Player.sprite:getHeight())
			 and love.keyboard.isDown('y') and Enemy2.x ~= Enemy.x then
		 Enemy.x = Player.x
		 Player.y = 175
		 Enemy.y = 165 
		 else
		 Enemy.y = 177
		end
		----Collision Player White enemies----
		 if CheckCollision(EnemyB.x , EnemyB.y, EnemyB.sprite:getWidth()  , EnemyB.sprite:getHeight(), Player.x, Player.y , Player.sprite:getWidth(), Player.sprite:getHeight())
			 and love.keyboard.isDown('x') and EnemyB2.x ~= EnemyB.x   then
		 EnemyB.x = Player.x
		 Player.y = 175
		 EnemyB.y = 165 
		 else
		 EnemyB.y = 177
		end
			----Collision Player Second White enemies----
		 if CheckCollision(EnemyB2.x , EnemyB2.y, EnemyB2.sprite:getWidth()  , EnemyB2.sprite:getHeight(), Player.x, Player.y , Player.sprite:getWidth(), Player.sprite:getHeight())
			 and love.keyboard.isDown('x') and EnemyB2.x ~= EnemyB.x    then
		 EnemyB2.x = Player.x
		 Player.y = 175
		 EnemyB2.y = 165 
		 else
		 EnemyB2.y = 177
		end
		  ------------------Collision with bomb to Grab
  if CheckCollision(Bomb.x, Bomb.y, Bomb.sprite:getWidth()  , Bomb.sprite:getHeight(), Player.x, Player.y , Player.sprite:getWidth(), Player.sprite:getHeight())
			 and love.keyboard.isDown("b") then
			Bomb.x = Player.x
	Bomb.y = Player.y - 10
		end
		--Collision Bomb on enemies DARKSTACK
		 if   CheckCollision( Bomb.x , Bomb.y, Bomb.sprite:getWidth()-10  , Bomb.sprite:getHeight() , Enemy2.x , Enemy2.y  , Enemy2.sprite:getWidth() -10 , Enemy2.sprite:getHeight())
			  and Enemy.x == Enemy2.x then
			--Enemy2.y = -10
			Bomb.y = 500
			Bomb.x = math.random(50, love.graphics.getWidth() - 210 )
			--Enemy2.x = math.random(100, love.graphics.getWidth() - 210 )
            Enemy2.x  = Enemy2.x + 600 
			--Enemy.x = math.random(50, love.graphics.getWidth() - 310 )
			Enemy.x = Enemy.x + 500
			Player.state = 'Explosion'
			score = score + 50
            end
			
				--Collision Bomb on enemies WHITESTACK
		 if   CheckCollision( Bomb.x , Bomb.y, Bomb.sprite:getWidth()-10  , Bomb.sprite:getHeight() , EnemyB2.x , EnemyB2.y  , EnemyB2.sprite:getWidth()-10  , EnemyB2.sprite:getHeight())
			  and EnemyB.x == EnemyB2.x then
			--Enemy2.y = -10
			Bomb.y = 500
			Bomb.x = math.random(50, love.graphics.getWidth() - 210 )
			--Enemy2.x = math.random(100, love.graphics.getWidth() - 210 )
            EnemyB2.x  = EnemyB2.x + 600 
			--Enemy.x = math.random(50, love.graphics.getWidth() - 310 )
			EnemyB.x = EnemyB.x + 500
			Player.state = 'Explosion2'
			score = score + 50
            end
			
				----Collision  Whiteenemies / Whiteenemies----
		 if CheckCollision(EnemyB.x , EnemyB.y, EnemyB.sprite:getWidth() -5 , EnemyB.sprite:getHeight(), EnemyB2.x , EnemyB2.y, EnemyB2.sprite:getWidth()  , EnemyB2.sprite:getHeight())
			then
			--Player.state = 'WhiteStack'
			EnemyB.x = EnemyB2.x 
			--+ 500
			EnemyB.y = EnemyB2.y - 15
			
			end
			
			if EnemyB.x > 400 and Enemy.x > 400  then
			Enemy2.x = math.random(100, love.graphics.getWidth() - 210 )
            Enemy.x = math.random(50, love.graphics.getWidth() - 310 )
			EnemyB2.x = math.random(100, love.graphics.getWidth() - 210 )
            EnemyB.x = math.random(50, love.graphics.getWidth() - 310 )
			score = score + 100
			end
		
		 

	end
   
   
   
   if love.keyboard.isDown('select') then love.event.quit() end
   
   
		

 

if Player.x < 47 then
Player.x = 47
end
  
 
   
   ----------PLayer Jump
    if Player.y_velocity ~= 0 then -- We're probably jumping
    Player.y = Player.y - Player.y_velocity * dt -- "dt" means we wont move at different speeds if the game lags
    Player.y_velocity = Player.y_velocity - gravity * dt
 
    if Player.y > 175 then -- We hit the ground again
      Player.y_velocity = 0
      Player.y = 175
    end
	end
  
  ------FIXES A GLITCH WITH PLAYER WALKING IN AIR BUT NEEDS TO BE DELETED
  if Player.x < 167 and Player.y_velocity == 0   then
  Player.y = 175
  end
  
   	----Collision Player enemies pick up----
		 if CheckCollision(Enemy.x , Enemy.y, Enemy.sprite:getWidth()  , Enemy.sprite:getHeight(), Player.x, Player.y , Player.sprite:getWidth(), Player.sprite:getHeight())
			 and love.keyboard.isDown('y') and Enemy2.x ~= Enemy.x   then
		 Enemy.x = Player.x
		 Player.y = 175
		 Enemy.y = 165 
		 else
		 Enemy.y = 177
		end
		   	----Collision Player /Enemy----
		 if CheckCollision(Enemy.x , Enemy.y, Enemy.sprite:getWidth() - 20  , Enemy.sprite:getHeight()-10, Player.x, Player.y , Player.sprite:getWidth() - 10, Player.sprite:getHeight())
			  then
		 Player.y = Player.y 
		 Player.x = Player.x - (20*dt) 
		 end
		----Collision  enemies / enemies----
		 if CheckCollision(Enemy.x , Enemy.y, Enemy.sprite:getWidth()  , Enemy.sprite:getHeight(), Enemy2.x , Enemy2.y, Enemy2.sprite:getWidth()  , Enemy2.sprite:getHeight())
			then
			--Player.state = 'Stack'
			--Enemy.x = Enemy.x + 500
			Enemy.x = Enemy2.x 
			--+ 500
			Enemy.y = Enemy2.y - 15
			end

		----Collision Player White enemies----
		 if CheckCollision(EnemyB.x , EnemyB.y, EnemyB.sprite:getWidth()  , EnemyB.sprite:getHeight(), Player.x, Player.y , Player.sprite:getWidth(), Player.sprite:getHeight())
			 and love.keyboard.isDown('x') and EnemyB2.x ~= EnemyB.x   then
		 EnemyB.x = Player.x
		 Player.y = 175
		 EnemyB.y = 165 
		 else
		 EnemyB.y = 177
		end
		  	----Collision Player /EnemyB----
		 if CheckCollision(EnemyB.x , EnemyB.y, EnemyB.sprite:getWidth() - 20  , EnemyB.sprite:getHeight()-10, Player.x, Player.y , Player.sprite:getWidth() - 10, Player.sprite:getHeight())
			  then
		 Player.y = Player.y 
		 Player.x = Player.x - (20*dt) 
		 end
			----Collision Player Second White enemies----
		 if CheckCollision(EnemyB2.x , EnemyB2.y, EnemyB2.sprite:getWidth()  , EnemyB2.sprite:getHeight(), Player.x, Player.y , Player.sprite:getWidth(), Player.sprite:getHeight())
			 and love.keyboard.isDown('x') and EnemyB2.x ~= EnemyB.x  then
		 EnemyB2.x = Player.x
		 Player.y = 175
		 EnemyB2.y = 165 
		 else
		 EnemyB2.y = 177
		end
		  	----Collision Player /EnemyB2----
		 if CheckCollision(EnemyB2.x , EnemyB2.y, EnemyB2.sprite:getWidth() - 20  , EnemyB2.sprite:getHeight()-10, Player.x, Player.y , Player.sprite:getWidth() - 10, Player.sprite:getHeight())
			  then
		 Player.y = Player.y 
		 Player.x = Player.x - (20*dt) 
		 end
			----Collision  Whiteenemies / Whiteenemies----
		 if CheckCollision(EnemyB.x , EnemyB.y, EnemyB.sprite:getWidth()  , EnemyB.sprite:getHeight(), EnemyB2.x , EnemyB2.y, EnemyB2.sprite:getWidth()  , EnemyB2.sprite:getHeight())
			then
		
			EnemyB.x = EnemyB2.x 
	
			EnemyB.y = EnemyB2.y - 15
			end
 

  
		
	 ------------------Collision with Enemy2 to Grab (second dark enemy)
  if CheckCollision(Enemy2.x, Enemy2.y,  Enemy2.sprite:getWidth(), Enemy2.sprite:getHeight() , Player.x, Player.y   , Player.sprite:getWidth(), Player.sprite:getHeight() + 10 )
			and love.keyboard.isDown("y") and Enemy2.x ~= Enemy.x   then
		 Enemy2.x = Player.x
		 Player.y = 175
		 Enemy2.y = 165 
		 else
		 Enemy2.y = 177
		 end
		   	----Collision Player /Enemy2----
		 if CheckCollision(Enemy2.x , Enemy2.y, Enemy2.sprite:getWidth() - 20  , Enemy2.sprite:getHeight()-10, Player.x, Player.y , Player.sprite:getWidth() - 10, Player.sprite:getHeight())
			  then
		 Player.y = Player.y 
		 Player.x = Player.x - (20*dt) 
		 end
		 

		 
		
		 
		
		

		---ONLY CODE LINKING PUZZLE AND WARIO WOOD. CAN THROW A BOMB TO REMOVE A TILE IN THE PUZZLE.
--		BUT CANNOT FIND UPDATED X,Y OF CARDS. SO IT ONLY BLOWS UP BOTTOMRIGHT CARD. NOT SURE IF WANT TO IMPLEMENT
	------------------------------------------------------------------------------------------------	
   ---Grabs every tile, grab x with width and use. 
   --tile:tile_position() will return the x and y of the tile.
	for tile, _ in pairs(self.tile_set) do
      tile:send("update", dt)
	  local tileX1, tileY1 = tile:tile_position()
	  local tileX2 = tileX1 - 35 
	  local tileY2 = tileY1 - 35
	  local oldColor = {love.graphics.getColor()}
	  --if CheckCollision(Bomb.x, Bomb.y, Bomb.sprite:getWidth(), Bomb.sprite:getHeight(), tileX1, tileY1, tileX2, tileY2) then
		--self.tile_set[tile] = nil 
		--Bomb.y = 300
		--Player.state = 'Explosion'
	  --end
    end


    if self.active_mode == "slide" then
      local should_merge = true
      for tile, _ in pairs(self.tile_set) do
        if tile:slide_active() then
          should_merge = false
          break
        else
          if tile.tile_merged_with then
            self.tile_set[tile] = nil
            tile.tile_merged_with.tile_value = tile.tile_merged_with.tile_value + tile.tile_value
          end
        end
      end
      if should_merge then
        self.active_mode = "input"
      end
    end
  end,

  grid_draw = function(self, offset_x, offset_y)
  --------------------------------------------------------------------------
  
 anim:draw(0, 0)
 love.graphics.setDepth(5)
 love.graphics.print("Score: " .. score, 252, 120)
 --love.graphics.draw(PlacedStack.sprite, PlacedStack.x, PlacedStack.y)
 love.graphics.draw(Player.sprite, Player.x, Player.y)
 --love.graphics.draw(Bomb.sprite, Bomb.x, Bomb.y)
 --love.graphics.draw(Enemy.sprite, Enemy.x, Enemy.y)
 love.graphics.draw(Enemy.sprite, Enemy.x, Enemy.y)
 love.graphics.draw(Enemy2.sprite, Enemy2.x, Enemy2.y)
 love.graphics.draw(EnemyB2.sprite, EnemyB2.x, EnemyB2.y)
 love.graphics.draw(EnemyB.sprite, EnemyB.x, EnemyB.y)
 love.graphics.setScreen('bottom')
 love.graphics.draw(BottomBG, 0, 0) 
   love.graphics.setScreen('top')
   -- Countdown Timer
   --love.graphics.print("Time " .. totalTime, 254, 124)
   
  --------Enemies Dropping
  for i, Bomb in ipairs(bombies) do
		love.graphics.draw(Bomb.sprite, Bomb.x, Bomb.y)
	end
	
	--Reset State
	if Player.state == 'Reset' then
	end
	
	
	--Bomb Explosion Animaiton
	if  Player.state == 'Explosion' then
		 BombAnim:draw(Player.x, Player.y - 15)
	end
	--Bomb Explosion Animaiton for white
	if  Player.state == 'Explosion2' then
		 BombAnim:draw(Player.x, Player.y - 15)
	end
 ---Bomb to Puzzle!  
 --if Bomb.y < 145 and Player.state == 'Normal' then 
 --Bomb.x = 155
 --Bomb.y = 120
 --end
   
   if love.keyboard.isDown("cpadleft") then
     PlayerLeftAnim:draw( Player.x, Player.y) elseif
	 love.keyboard.isDown("cpadright") then
	 PlayerRightAnim:draw( Player.x, Player.y)
	 else
	  love.graphics.draw(PlayerRight, Player.x, Player.y)
	 end
  --------------------------------------------------------------------------- 
    local grid_offset_x = 56 + offset_x
    local grid_offset_y = 16 + offset_y

    graphics:set_color(color.GRAY)
    for y = 0, 4 do
      graphics:draw_rect(grid_offset_x, grid_offset_y + (tile.tile_height * y), tile.tile_width * 4, 1)
    end
    for x = 0, 4 do
      graphics:draw_rect(grid_offset_x + (tile.tile_width * x), grid_offset_y, 1, tile.tile_height * 4)
    end

    for tile, _ in pairs(self.tile_set) do
      tile:send("draw", grid_offset_x, grid_offset_y)
    end

   
   
  end,
----------------------------------------------
  move = function(self, direction)
    if self.active_mode ~= "input" then
      print "not in active mode"
      return
    end

    local newgrid = grid_funcs.move(self.tile_grid, direction)

    for y = 1, newgrid.h do
      for x = 1, newgrid.w do
        local tile = newgrid:get(x, y)
        if tile then
          local x, y = (x-1)*tile.tile_width, (y-1)*tile.tile_height
          tile:slide_to(x, y)
        end
      end
    end

    for tile, _ in pairs(self.tile_set) do
      if tile.tile_merged_with then
        local x, y = tile.tile_merged_with:slide_target()
        tile:slide_to(x, y)
      end
    end

    self.active_mode = "slide"
    self.tile_grid = newgrid
  end,
}

game_grid = object(grid_component, game_controls, {
  _init = function(self)
    self:controls_init()
    self:grid_init()
  end
})

game_mode = object({

  _init = function(self)
    self.grid = game_grid()
    self.mode = nil
    self:on("draw", self:bind(self.game_draw))
    self:on("update", self:bind(self.game_update))
  end,

  game_draw = function(self, offset_x, offset_y)
    self.grid:send("draw", offset_x, offset_y)
	love.graphics.setDepth(-1)
  end,

  game_update = function(self, dt)
    if self.grid.active_mode ~= self.mode then
      self:change_state(self.mode, self.grid.active_mode)
    end

    self.grid:send("update", dt)
	 
	 ------------------End Game----------------------------------------------------------
	 --if love.keyboard.isDown("down") then self:send("gameover") 
	--end
	
	
  end,
  
 
  
  change_state = function(self, from, to)
    print("mode", from, to)
    if to == "input" then
      local continue = self.grid:randomly_add_tile(tile({
        tile_value = random() < 0.9 and 2 or 4,
      }))

      if continue == "gameover" then
        self:send("gameover")
      end
    end
    self.mode = to
  end,
})

title_mode = object({
  _init = function(self)
    self:on("draw", self:bind(self.title_draw))
    self:on("update", self:bind(self.title_update))
    self.clock = 0
  end,
  title_update = function(self, dt)
    self.clock = self.clock + dt
    if input.tap.menu_enter then self:send("start") 
	score = 0
	end
  end,
  title_draw = function(self)
    if self:send("gameover") then
      graphics:set_color(color.PUREWHITE)
      --graphics:write("center", "center", "PRESS ENTER TO START")
	  love.graphics.draw(StartMenu, 0, 0)
	  love.graphics.print(": " .. score, 270, 67)
    end
  end
})


main = object {
  load = function(self)
    graphics:init()
    input:reset()
    self:restart()
  end,

  update = function(self, dt)
    if dt > 0.2 then dt = 0.2 end

    input:update(dt)

    if input.tap.screenshot then graphics:save_screenshot() end
    if input.tap.changescale then graphics:next_scale() end
    if input.tap.debug_terminate then love.event.quit() end
    if input.tap.debug_reset then self:restart() end
    if input.tap.fullscreen then graphics:toggle_fullscreen() end

    self.mode:send("update", dt)

    timer:update_timers(dt)
  end,

  draw = function(self)
    graphics:start()
    self.mode:send("draw", 0, 0)
    graphics:stop()
  end,

  resize = function(self, w, h)
    graphics:on_resize(w, h)
  end,

  restart = function(self)
    self.mode = title_mode()
    self.mode:on("start", self:bind(self.start))
  end,

  start = function(self)
    self.mode = game_mode()
    self.mode:on("gameover", self:bind(self.restart))
  end,
}


-- Fill out love event handlers with Main object calls
for _, callback in ipairs({ "load", "update", "draw", "resize" }) do
  love[callback] = function(...)
    RESET_DEBUG_HOOK()
    main[callback](main, ...)
  end
end

-- All input controls go to the input singleton
for _, callback in ipairs {
  "keypressed", "keyreleased", "textinput",
  "gamepadpressed", "gamepadreleased", "gamepadaxis"
} do
  love[callback] = function(...)
    input[callback](input, ...)
  end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		   x2 < x1+w1 and
		   y1 < y2+h2 and
		   y2 < y1+h1
end




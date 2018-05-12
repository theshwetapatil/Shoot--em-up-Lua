vector = require 'vector'
-------------------------
-- main.lua : Defines the entry point for the windows application.
-- Game Programming: Shmup/SGT Shooter Game
-- Gameplay Features: Vector Math, Collision Detection
-- Author: Shweta Patil
-- Copyright: Shweta Patil © 2018
--

-------------------------
-- LOVE callbacks
--
function love.load()
  love.window.setTitle("shooter")
  love.window.setIcon(girlImage:getData())
  love.graphics.setBackgroundColor(0,255,0,10)
  dis=0
  start = vector.new((love.window.getWidth()/2)-10, love.window.getHeight()-100)
  dir = vector.new((love.window.getWidth()/2)-10,10) - start
   bullets = {}
   targets = {}
   destroy = 0
   angle = 0

   targetImage = love.graphics.newImage("deer.png")
   shooterImage = love.graphics.newImage("shoot.png")
   swidth=shooterImage:getWidth()
   sheight=shooterImage:getHeight()
   COLLISION_DISTANCE = targetImage:getWidth()/2
   uniquifier = 0
   
   -- setup targets
   spawnCount = 10
   spawnTargets ( spawnCount )
   lastSpawnTime = love.timer.getTime()
   spawnDelay = 5
end

function love.mousepressed( x, y, button )
   if love.mouse.isDown then
     local start = vector.new(love.window.getWidth()/2, love.window.getHeight())
     local speed = 1000
     local dir = vector.new(x,y) - start
     dir:normalize_inplace()
     createNewBullet ( start, dir * speed )
   end
end

function love.keypressed(key)
  if key == " " then
   local speed = 1000
   dir:normalize_inplace()
   createNewBullet ( start, dir * speed )
   love.graphics.printf("Score "..30, love.window.getWidth()/2, love.window.getHeight()/2,1000,"left")
  end 

end

function love.draw()
   for id,ent in pairs(targets) do
	  ent:draw()
   end
   for id,ent in pairs(bullets) do
     ent:draw()
   end
   love.graphics.draw(shooterImage,love.window.getWidth()/2+10+dis,love.window.getHeight()-60, math.rad(angle), 1, 1, swidth / 2,    sheight / 2)
end

function love.update(dt)

   time = love.timer.getTime()
   if time  > lastSpawnTime + spawnDelay then
      lastSpawnTime = time
      spawnTargets ( math.random(1,spawnCount) )
   end

   for id,ent in pairs(targets) do
     ent:update(dt)
   end
   for id,ent in pairs(bullets) do
     ent:update(dt)
   end
  
   if love.keyboard.isDown("right") then
   dis=dis+1
   start = vector.new((love.window.getWidth()/2)-10+dis, love.window.getHeight()-100)
   dir = vector.new((love.window.getWidth()/2)-10+dis,10) - start
   end
 
   if love.keyboard.isDown("left") then
   dis=dis-1
   start = vector.new((love.window.getWidth()/2)-10+dis, love.window.getHeight()-100)
   dir = vector.new((love.window.getWidth()/2)-10+dis,10) - start
   end
end

-----------------------------------
-- bullets
--

function createNewBullet ( pos, vel )
   local bullet = {}
   bullet.pos = vector.new(pos.x, pos.y)
   bullet.lastpos = pos
   bullet.vel = vector.new(vel.x,vel.y)
   bullet.id = getUniqueId()
   bullets[bullet.id] = bullet

   function bullet:checkForCollision ()
      -- return id of collided object (first found)
      for id,target in pairs(targets) do
         if (target.pos - self.pos):len() < COLLISION_DISTANCE then
            return id
         end
      end
      return nil
   end

   function bullet:update ( dt ) 
      self.lastpos = self.pos
      self.pos = self.pos + self.vel * dt
      local hit = self:checkForCollision ()
      if hit then 
       bullets[self.id] = nil
       targets[hit] = nil
       destroy = destroy + 1
       print("score "..destroy)
       love.graphics.printf("Score "..destroy, love.window.getWidth()/2, love.window.getHeight()/2,100,"left")
       --love.window.showMessageBox("score", destroy, "error")
      end
      -- also check if off-screen 
      if self.pos.y>love.window.getHeight() then
        bullets[self.id] = nil
      end  
      if self.pos.x>love.window.getWidth() then
        bullets[self.id] = nil
      end
   end

   function bullet:draw ()
      love.graphics.line ( self.lastpos.x, self.lastpos.y, 
                           self.pos.x, self.pos.y )
   end

   return bullet
end


--------------------------
-- target
--

function createNewTarget ( pos, vel )
   local target = {}
   target.pos = vector.new(pos.x, pos.y)
   target.vel = vector.new(vel.x, vel.y)
   target.angle = 0
   target.id = getUniqueId()
   targets[target.id] = target

   function target:update (dt)
      self.pos = self.pos + self.vel * dt
      -- also check for off-screen...
      if self.pos.x>love.window.getWidth() then
         targets[self.id] = nil
      end
      if self.pos.y>love.window.getHeight()-200 then
         targets[self.id] = nil
      end
   end

   function target:draw ()
      love.graphics.draw ( targetImage, self.pos.x, self.pos.y , self.angle , 1,1,
         targetImage:getWidth()/2, targetImage:getHeight()/2 )
   end

   return target
end

-----------------------
--shooter
-----------------------
-- helpers
--

function getUniqueId ()
   uniquifier = uniquifier + 1
   return uniquifier
end

function spawnTargets ( N )
   for i = 1,N do
      local pos = vector.new ( love.math.random( 10, love.window.getWidth()-10), 
                              -love.math.random(10,100) )
      local vel = vector.new ( 0,50 )
      createNewTarget ( pos, vel )
   end
end
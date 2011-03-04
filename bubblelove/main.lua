BubbleClass = {}

function BubbleClass.new( x, y )
    local b = {}
    setmetatable(b, {__index=BubbleClass})
    local mass = 15
    local radius = 5
    b.body = love.physics.newBody(world, x, y + 50, mass, 0)
    b.shape = love.physics.newCircleShape(b.body, 0, 0, radius)
    b.color = { 193, 47, 14, 255 }  
    return b
end

function BubbleClass:Draw()
    love.graphics.setColor( self.color ) 
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius(), 20)
end
----------------------------------------------------------------------------------------------------
WallClass = {}

function WallClass.new( x, y, width, height)
    local w = {}
    setmetatable(w, {__index=WallClass})
    w.width = width
    w.height = height
    w.body = love.physics.newBody(world, x, y, 0, 0)
    w.shape = love.physics.newRectangleShape( w.body, 0, 0, width, height, 0 )
    
    return w
end

function WallClass:Draw()
    love.graphics.setColor(72, 160, 14)
    love.graphics.rectangle("fill", self.body:getX() - self.width/2, self.body:getY() - self.height/2, self.width, self.height)
end

----------------------------------------------------------------------------------------------------
function love.load()
  world = love.physics.newWorld(-650, -650, 650, 650) --create a world for the bodies to exist in with width and height of 650
  world:setGravity(0, 0) --the x component of the gravity will be 0, and the y component of the gravity will be 700
  world:setMeter(64) --the height of a meter in this world will be 64px
 
  bodies = {} --create tables for the bodies and shapes so that the garbage collector doesn't delete them
  shapes = {}
  objects = {}
    
  --let's create the ground
  --we need to give the ground a mass of zero so that the ground wont move
  --bodies[0] = love.physics.newBody(world, 650/2, 625, 0, 0) --remember, the body anchors from the center of the shape
  --shapes[0] = love.physics.newRectangleShape(bodies[0], 0, 0, 650, 50, 0) --anchor the shape to the body, and make it a width of 650 and a height of 50
 
  V = BubbleClass.new( 650/2, 650/2 + 50)
  V.color = { 255, 0, 0, 255 }  
  table.insert( objects, V )

  for i=1,1000 do
    table.insert( objects, BubbleClass.new( 50 + i * 2, 650/2 ) )
  end
  
  table.insert( objects, WallClass.new( 650/2, 625, 650, 50 ) )
  table.insert( objects, WallClass.new( 650/2, 25, 650, 50 ) )
   
    table.insert( objects, WallClass.new( 25 , 650/2, 50, 650 ) )
    table.insert( objects, WallClass.new( 625 , 650/2, 50, 650 ) )
  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.graphics.setMode(650, 650, false, true, 0) --set the window dimensions to 650 by 650
end


function love.update(dt)
  world:update(dt) --this puts the world into motion
  local F = 700
 
  --here we are going to create some keyboard events
  if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
    V.body:applyForce(F, 0)
  end
  if love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
    V.body:applyForce(-F, 0)
  end
  if love.keyboard.isDown("up") then 
     V.body:applyForce( 0, -F)
  end
  if love.keyboard.isDown("down") then 
     V.body:applyForce( 0, F)
  end
end

function love.draw()
 -- local x1, y1, x2, y2, x3, y3, x4, y4 = shapes[0]:getBoundingBox() --get the x,y coordinates of all 4 corners of the box.
  --x1, y1 represent the bottom left corner of the bounding box
  --x2, y2 represent the top left corner of the bounding box
  --x3, y3 represent the top right corner of the bounding box
  --x4, y4 represent the top right corner of the boudning box
 -- local boxwidth = x3 - x2 --calculate the width of the box
  --local boxheight = y2 - y1 --calculate the height of the box
  --love.graphics.setColor(72, 160, 14) --set the drawing color to green for the ground
  --the rectangle is drawing from the top left corner
  --so we need to compensate for that
  --love.graphics.rectangle("fill", bodies[0]:getX() - boxwidth/2, bodies[0]:getY() - boxheight/2, boxwidth, boxheight)
  --love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  --the circle is drawing from the center
  --so we do not need to compensate
  for _, o in pairs( objects ) do
    o:Draw()
  end 
end
BubbleClass = {}
bubbleId = 0
nbLink = 0
function BubbleClass.new( x, y )
    local b = {}
    setmetatable(b, {__index=BubbleClass})
    local mass = 15
    local radius = 5
    b.body = love.physics.newBody(world, x, y + 50, mass, 0)
    b.shape = love.physics.newCircleShape(b.body, 0, 0, radius)
    b.shape:setData( b )
    b.name = "Bubble"
    b.color = { 193, 47, 14, 255 }  
    b.bubble = true --todo change
    b.id = bubbleId
    bubbleId = bubbleId + 1
    b.jointBubbles = {}
    return b
end

function BubbleClass:Draw()
    love.graphics.setColor( self.color ) 
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius(), 20)
end

function BubbleClass:Fire()
      table.insert( objects, BubbleClass.new( self.body:getX() , self.body:getY() ) )
end

function BubbleClass:Join( withBubble, createJoin )

    if table.getn( self.jointBubbles ) > 6 then
        return
    end
    --Already joint
    if self.jointBubbles[ withBubble.id ] then 
        return 
    end

    if createJoin then
        local joint = love.physics.newDistanceJoint( self.body, withBubble.body, self.body:getX() , self.body:getY(), withBubble.body:getX(), withBubble.body:getY() )
        joint:setCollideConnected( false )
        joint:setDamping( 0 )
        joint:setLength( self.shape:getRadius() + withBubble.shape:getRadius() + 5 )
        withBubble:Join( self, false )
        nbLink = nbLink + 1
    end
    self.jointBubbles[ withBubble.id ] =  withBubble
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
    w.shape:setData( w )
    w.name = "Wall"
    return w
end

function WallClass:Draw()
    love.graphics.setColor(72, 160, 14)
    love.graphics.rectangle("fill", self.body:getX() - self.width/2, self.body:getY() - self.height/2, self.width, self.height)
end

text = ""

function add(a, b, coll)
    --text = text..a.name.." collding with "..b.name.." at an angle of "..coll:getNormal().."\n"
    if a.Join and b.Join then
     text = text .. "Join"
        a:Join( b, true )
    end
end

function persist(a, b, coll)
    text = text..a.name.." touching "..b.name.."\n"
    --if a.Join and b.Join then
    -- text = text .. "Join"
    --    a:Join( b )
    --end
end

function rem(a, b, coll)
    text = text..a.name.." uncolliding "..b.name.."\n"
end

function result(a, b, coll)
    text = text..a.name.." hit "..b.name.."resulting with "..coll:getNormal().."\n"
end

----------------------------------------------------------------------------------------------------
function love.load()
  world = love.physics.newWorld(-650, -650, 650, 650) --create a world for the bodies to exist in with width and height of 650
  world:setCallbacks(add, persist, rem, result)
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
  T = BubbleClass.new( 650/2, 650/2 + 100 )
 table.insert( objects, T )
 
  for i=1,50 do
    table.insert( objects, BubbleClass.new( 50 + i * 10, 650/2 ) )
  end
-- joint = love.physics.newDistanceJoint( V.body, T.body, 650/2, 650/2 + 50, 650/2, 650/2 + 100 )
  
  table.insert( objects, WallClass.new( 650/2, 625, 650, 50 ) )
  table.insert( objects, WallClass.new( 650/2, 25, 650, 50 ) )
   
    table.insert( objects, WallClass.new( 25 , 650/2, 50, 650 ) )
    table.insert( objects, WallClass.new( 625 , 650/2, 50, 650 ) )
  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.graphics.setMode(650, 650, false, true, 0) --set the window dimensions to 650 by 650
end


function love.update(dt)
text = nbLink .. ""
  world:update(dt) --this puts the world into motion
  local F = 1000
 
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

  for _, o in pairs( objects ) do
    o:Draw()
  end 
   love.graphics.setColor( 0,0,0,255 ) 
  love.graphics.print(text,0,12)
end
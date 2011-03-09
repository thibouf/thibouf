require( "BubbleClass" )
require( "Wall" )
require( "Vessel" )
require( "Math" )

text = ""
----------------------------------------------------------------------------------------------------
-- Physic callbacks
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
 
  V = Vessel:new( 650/2, 650/2 + 50 , "Red" )
  table.insert( objects, V )
  V.protected = true
  
  T = BubbleClass:new( 650/2, 650/2 + 100 , "White" )
   T.body:setMass( 50/2, 650/2 + 50, 0, 0 )
 table.insert( objects, T )
 
  for i=1,10 do
    table.insert( objects, BubbleClass:new( 50 + i * 10, 650/2, "Blue"  ))
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
text = love.timer.getFPS() .. " - "
 for k, o in pairs( objects ) do
        if o.RealDestroy then
            o:RealDestroy()
           -- objects[o] = nil
        end
  end    
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
    
    for k, o in pairs( objects ) do
        o:Draw()
        if o.RealDestroy then
            o:RealDestroy()
           -- objects[o] = nil
        end
  end       
    
end

function love.mousepressed( x, y, button )
   if button == "l" then
        V:Fire()
   elseif button == "r" then
        V:Fire2()
   
    elseif button == "wd" then
        V:NextColor( )
    elseif button == "wu" then
        V:SetColor( "Red" )
   end
end

function love.keypressed(key, u)
   --Debug
   if key == "rctrl" then --set to whatever key you want to use
      debug.debug()
   end
end

function love.draw()

  for _, o in pairs( objects ) do
    o:Draw()
  end 
   love.graphics.setColor( 0,0,0,255 ) 
  love.graphics.print(text,0,12)
  
 
  
end
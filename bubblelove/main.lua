require( "BubbleClass" )
require( "Wall" )
require( "Vessel" )
require( "Towel" )
require( "Target" )

require( "Math" )

text = ""
----------------------------------------------------------------------------------------------------
-- Physic callbacks
function add(a, b, coll)
    --text = text..a.name.." collding with "..b.name.." at an angle of "..coll:getNormal().."\n"
    
    if a.NotifyCollide then
        a:NotifyCollide( b )
    end
    if b.NotifyCollide then
        b:NotifyCollide( a )
    end
    
    if a.Join and b.Join then
     text = text .. "Join"
        a:Join( b, true )
    end
end

function persist(a, b, coll)
    text = text..a.name.." touching "..b.name.." dist" .. coll:getSeparation( ) .."\n"
    
    if a.NotifyCollide then
        a:NotifyCollide( b )
    end
    if b.NotifyCollide then
        b:NotifyCollide( a )
    end
    
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
    world:setGravity(0, 50) -- the x component of the gravity will be 0, and the y component of the gravity will be 700
    world:setMeter(64) --the height of a meter in this world will be 64px

    objects = {}
    
    V = Vessel:new( 650/2, 650/2 + 50 , "Red" )
        
    table.insert( objects, Target:new( 650/2, 650 - 50, 650, 50, "Special", V ) )
    -- table.insert( objects, Target:new( 650/2, 650 - 60, 650, 10, "Blue" ) )  
    -- table.insert( objects, Target:new( 650/2, 650 - 70, 650, 10, "Yellow" ) )  
    -- table.insert( objects, Target:new( 650/2, 650 - 80, 650, 10, "Cyan" ) )  
    -- table.insert( objects, Target:new( 650/2, 650 - 90, 650, 10, "Purple" ) )  
    -- table.insert( objects, Target:new( 650/2, 650 - 100, 650, 10, "Green" ) )  
    

    table.insert( objects, WallClass.new( 650/2, 625, 650, 50 ) )
    table.insert( objects, WallClass.new( 650/2, 25, 650, 50 ) )
   
    table.insert( objects, WallClass.new( 25 , 650/2, 50, 650 ) )
    table.insert( objects, WallClass.new( 625 , 650/2, 50, 650 ) )
    table.insert( objects, WallClass.new( 650/2 , 650 - 50, 50, 100 ) )

    
    table.insert( objects, V )
    V.protected = true

  
    J = BubbleClass:new( 650/2,  100 , "Special" )
    J.body:setMass( 50/2, 650/2 + 50, 0, 0 )
    table.insert( objects, J )
 
   T = Towel:new(  70,  300 , J )
    table.insert( objects, T )
  
    T2 = Towel:new(  650-70,  300 , J )
    table.insert( objects, T2 )
 
 
  -- for i=1,3 do
    -- table.insert( objects, BubbleClass:new( 10 + i * 30, 400, "Blue"  ))
  -- end

    
  --initial graphics setup
  love.graphics.setBackgroundColor(0, 0, 0) --set the background color to a nice blue
  love.graphics.setMode(650, 650, false, true, 0) --set the window dimensions to 650 by 650
end


function love.update(dt)
    text = love.timer.getFPS() .. " - "
  
  world:update(dt) --this puts the world into motion
  local F = 1000
    V:ResetEngineForce()
  --here we are going to create some keyboard events
  if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
    V:AddEngineForce(F, 0)
  end
  if love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
    V:AddEngineForce(-F, 0)
  end
  if love.keyboard.isDown("up") then 
     V:AddEngineForce( 0, -F)
  end
  if love.keyboard.isDown("down") then 
     V:AddEngineForce( 0, F)
  end
    
    for k, o in pairs( objects ) do
        
        if o.RealDestroy and o.realDestroyed then
            --o:RealDestroy()
            objects[k] = nil
        else
            if o.Update then
                o:Update(dt)
            end
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
    if o.Draw then
        o:Draw()
    end
  end 
   love.graphics.setColor( 0,0,0,255 ) 
  love.graphics.print(text,0,12)
  
 
  
end
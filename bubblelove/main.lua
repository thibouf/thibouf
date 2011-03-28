require( "BubbleClass" )
require( "Wall" )
require( "Vessel" )
require( "Tower" )
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
    
    if a.Join and b.Join then
     text = text .. "Join"
        a:Join( b )
    end
end

function rem(a, b, coll)
    text = text..a.name.." uncolliding "..b.name.."\n"
end

function result(a, b, coll)
    text = text..a.name.." hit "..b.name.."resulting with "..coll:getNormal().."\n"
end


function GenerateLevel()
    objects = {}
    DONNOTDESTROY = true
    V = Vessel:new( 50,  200 , BubbleClass.static.GetColorByName(  "Red" )  )
    V:SetMass( 50 )
    table.insert( objects, V )
    
   
    for x= 1, 20, 1  do

        for y=1, 10, 1 do
            if y == 1 then
                color = BubbleClass.static.GetColorByName( "Special" )
                mass = 0
            else
                color = math.random( 6 ) --% table.getn( BubbleClass.static.BubbleColors )
                mass = nil
            end

            if (y % 2 == 0 ) then
                padding = BubbleClass.static.Radius
            else
                padding = 0
            end
            local B = BubbleClass:new( x * ( BubbleClass.static.Radius * 2 - 1 )+ padding,  y * ( BubbleClass.static.Radius * 1.7)  , color , mass )
            B.ready = true
            B.shape:setSensor( false )
            table.insert( objects, B )
        end
    end

end

function InitLevel( name ) 
    objects = {}
    DONNOTDESTROY = true
    local fullname = "levels/" .. name
    package.loaded[fullname] = nil
	local level  = require( fullname )
    local T
	for Id, att in pairs( level ) do
		if att.T == "Wall" then
			table.insert( objects, WallClass.new( att.x, att.y,  att.w, att.h ) )
		elseif att.T == "Bubble" then
			local B = BubbleClass:new( att.x,  att.y , BubbleClass.static.GetColorByName( att.color ) , att.mass )
			B.ready = true
            B.shape:setSensor( false )
			table.insert( objects, B )
	
		elseif att.T == "Vessel" then
		 	V = Vessel:new(  att.x,  att.y , BubbleClass.static.GetColorByName( att.color )  )
			table.insert( objects, V )

		elseif att.T == "Tower" then
		 	local T = Tower:new(  att.x,  att.y , objects[ att.target ], att.force  )
            T:SetStepsDef( att.steps, 1 )
			table.insert( objects, T )
        elseif att.T == "Target" then
            local T = Target:new(  att.x,  att.y ,   att.w, att.h, BubbleClass.static.GetColorByName( att.color ), V )
            table.insert( objects, T )
		end
	end
end

function InitWorld()
    world = love.physics.newWorld(0, 0, 1024, 1024) --create a world for the bodies to exist in with width and height of 650
    world:setCallbacks(add, persist, rem, result)
    world:setGravity(0, 50) -- the x component of the gravity will be 0, and the y component of the gravity will be 700
    world:setMeter(64) --the height of a meter in this world will be 64px
 	--InitLevel( "lvl1" ) 
    GenerateLevel()
end
----------------------------------------------------------------------------------------------------
function love.load()
	InitWorld()
  
  --initial graphics setup
  love.graphics.setBackgroundColor(0, 0, 0) 
  love.graphics.setMode(1024, 768, false, true, 0) --set the window dimensions to 650 by 650
end


function love.update(dt)
    text = love.timer.getFPS() .. " - "
  
  world:update(dt) --this puts the world into motion
  local F = 400
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
    
    if DONNOTDESTROY then
            DONNOTDESTROY = false
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
        V:PrevColor( )
    elseif button == "m" then
        V:SetColor( BubbleClass.static.GetColorByName("Special" ) )
    end
end


function SaveGame()
	savedGame = {}
  for _, o in pairs( objects ) do
	table.insert( savedGame , o )
  end 
end

function LoadGame()
	InitWorld()

  -- for _, o in pairs( savedGame ) do
	-- if o.name == "Bubble" then
	 	-- local B = BubbleClass:new( o.body:getX(), o.body:getY(),  o.colorId )
		-- B.ready = true
		-- B:SetMass( o.body:getMass() )
 		-- B.shape:setSensor( false )
     	-- table.insert( objects, B )
	-- end
  -- end 
end

function love.keypressed(key, u)
   --Debug
   	if key == "rctrl" then --set to whatever key you want to use
      debug.debug()
   	elseif key == "s" then
		SaveGame()
	elseif key == "l" then
		LoadGame()
	end
end


function GetMousePosition()
	 local x, y = love.mouse.getPosition( )
	return x - diffX, y - diffY 
end

function love.draw()
	local initx = 650/2
	local inity = 650/2
	local targetx= V.body:getX() 
	local targety= V.body:getY() 
	local minX = 650/2 
	local minY = 650/2
	local maxX = 650/2 
	local maxY = 650/2
	if targetx < minX then
		targetx = minX
	end
	if targety < minY then
		targety = minY
	end
	if targetx > maxX then
		targetx = maxX
	end
	if targety > maxY then
		targety = maxY
	end

	diffX = initx - targetx
	diffY = initx - targety

	love.graphics.translate( diffX, diffY)


  for _, o in pairs( objects ) do
    if o.Draw then
        o:Draw()
    end
  end 
   love.graphics.setColor( 0,0,0,255 ) 
  -- love.graphics.print(text,0,12)
  
 
  
end

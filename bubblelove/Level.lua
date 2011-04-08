require( "BubbleClass" )
require( "Wall" )
require( "Vessel" )
require( "Tower" )
require( "Target" )

require( "YaciCode" )


Level = class("Level")

function Level:init( name )
    self.levelName = name
    self:Load()
end

function Level:Load()
    local name = self.levelName
    self.objects = {}
    DONNOTDESTROY = true
    
    local fullname = "levels/" .. name
    package.loaded[fullname] = nil
	local level  = require( fullname )
    
    
    self.world = love.physics.newWorld(0, 0, 1024, 1024) --create a world for the bodies to exist in with width and height of 650
    self.world:setCallbacks(add, persist, rem, result)
    self.world:setGravity(0, 50) -- the x component of the gravity will be 0, and the y component of the gravity will be 700
    self.world:setMeter(64) --the height of a meter in this world will be 64px

    local T
	for Id, att in pairs( level ) do
		if att.T == "Wall" then
			table.insert( self.objects, WallClass.new( self, att.x, att.y,  att.w, att.h ) )
		elseif att.T == "Bubble" then
			local B = BubbleClass:new( self, att.x,  att.y , BubbleClass.static.GetColorByName( att.color ) , att.mass )
			B.ready = true
            B.shape:setSensor( false )
			table.insert( self.objects, B )
	
		elseif att.T == "Vessel" then
		 	V = Vessel:new( self, att.x,  att.y , BubbleClass.static.GetColorByName( att.color ), att.mass  )
			table.insert( self.objects, V )

		elseif att.T == "Tower" then
		 	local T = Tower:new( self, att.x,  att.y , self.objects[ att.target ], att.force  )
            T:SetStepsDef( att.steps, 1 )
			table.insert( self.objects, T )
        elseif att.T == "Target" then
            local T = Target:new(  self, att.x,  att.y ,   att.w, att.h, BubbleClass.static.GetColorByName( att.color ), V )
            table.insert( self.objects, T )
        elseif att.T == "RandomZone" then
            self:GenerateRandomZone(  att.x,  att.y , att.nx,  att.ny )
		end
	end
end


function Level:GenerateRandomZone( startX, startY, nx, ny )
    
    for x= 1, nx, 1  do
        for y=1, ny, 1 do
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
            local B = BubbleClass:new( self, startX + x * ( BubbleClass.static.Radius * 2 - 1 )+ padding, startY + y * ( BubbleClass.static.Radius * 1.7)  , color , mass )
            B.ready = true
            B.shape:setSensor( false )
            table.insert( self.objects, B )
        end
    end
end

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
-- End of  Physic callbacks
----------------------------------------------------------------------------------------------------






function Level:Update( dt )

  self.world:update(dt) --this puts the world into motion

    
    for k, o in pairs( self.objects ) do
        
        if o.RealDestroy and o.realDestroyed then
            --o:RealDestroy()
            self.objects[k] = nil
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

function Level:MousePressed( x, y, button )
   V:MousePressed( x, y, button )
end

function Level:KeyPressed( key, u )
    V:KeyPressed(  key, u )
	if key == "l" then
        self:Load( )
    elseif key == "escape" then
         GotoState( "Menu" )
    end
end

function Level:Draw()
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


    for _, o in pairs( self.objects ) do
        if o.Draw then
            o:Draw()
        end
    end 
end

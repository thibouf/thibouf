require( "BubbleClass" )
require( "Math" )

Vessel = class( "Vessel" )

function Vessel:init( x, y, colorId )
    self.Radius = 10
    -- self.Mass = 50
        self.Mass = 0
    self.name = "Vessel"
    -- self.super:init( x, y, color )
    self.body = love.physics.newBody( world, x, y , self.Mass, 0 )
    self.body:setLinearDamping( 0.2 ) 
    self.shape = love.physics.newCircleShape(self.body, 0, 0, self.Radius + 1 )
    self.shape:setData( self )
    self.shape:setRestitution( 1 )
    self.shape:setFriction( 0 )
    --world:update(0)
    -- self.shape:setMask(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16)
    self.shape:setCategory( 16 )
    -- self.shape:setMask( 1 )
    -- world:update(0)
    
    
    self.x = w
    self.y = y
    self:SetColor( colorId )



    self.image = love.graphics.newImage( "test.png" )
    self.particleSystem = love.graphics.newParticleSystem( self.image, 100 )

    self.particleSystem:setEmissionRate(100)
    self.particleSystem:setSpeed(100, 200)
    self.particleSystem:setGravity(0)
    self.particleSystem:setSize(0.1, 1,1)
   	--self.particleSystem:setSizeVariation(10)
    self.particleSystem:setColor(255, 255, 255, 255, 58, 128, 255, 0)
    self.particleSystem:setPosition(400, 300)
    self.particleSystem:setLifetime(-1)
    self.particleSystem:setParticleLife(0.3)
    self.particleSystem:setDirection(0)
    self.particleSystem:setSpread(1)
    self.particleSystem:setSpin(0,1,1)

    self.particleSystem:start()
    
    self.ammoPerColor = {}
    self.creationTime = love.timer.getTime( )
    for cId, c in pairs( BubbleClass.static.BubbleColors ) do
         self.ammoPerColor[ cId ] = 10
    end
    
    self:CreateBubble()
    
end

function Vessel:SetMass( m )
    self.body:setMass( self.body:getX(), self.body:getY(), m, 0 )
end

function Vessel:onBubbleDestroyed( wasReady )
 

    if not wasReady then
         self:AddAmmo( self.bubble.colorId )
     else
     table.insert( objects, self.bubble )
    end
    self.bubbleJoint:destroy()
    -- self.bubbleJoint = nil
    self.bubble = nil
end

function Vessel:ReleaseBubble()
    -- self.bubble:SetMass( self.bubble.Mass )
    -- self:SetMass( self.Mass )
    if self.bubble then
		table.insert( objects, self.bubble )
		self.bubble:SetMass( self.bubble.Mass )
		self.bubbleJoint:destroy()
		self.bubbleJoint = nil
		self.bubble.onDestroyCallback = nil

		self.bubble = nil
	end

end

function Vessel:CreateBubble()
    if  self.ammoPerColor[ self.colorId ] == 0 then
        cId, color = BubbleClass.static.GetColorByName( "Special" )
        self:SetColor( cId )
        return
    end
    
    if self.color.name == "Special" then
        return
    end

    if self.bubble or self.ammoPerColor[ self.colorId ] <= 0 then
        return
    else
       self:ConsumeAmmo()
    end
    
    self.bubble = BubbleClass:new(  self.body:getX() , self.body:getY()  , self.colorId )
    self.bubble:SetMass( 2 )
    self.bubbleJoint = love.physics.newRevoluteJoint(  self.body, self.bubble.body, self.body:getY(), self.bubble.body:getX() )
    self.bubbleJoint:setCollideConnected( true )

    self.bubble.onDestroyCallback = { f = self.onBubbleDestroyed, p = self }

end

function Vessel:SetColor( color )
    self.colorId = color   
    self.color = BubbleClass.static.BubbleColors[ color ]
    assert( self.color, "SetColor with unknow color " .. color )
    if self.bubble then
        if self.color.name == "Special" then
            local b = self.bubble
            self:ReleaseBubble()
            b:Destroy()

        else
            self.bubble:SetColor( self.colorId )
            self.bubble:StartCheckDestroy()
        end
    end
end

function Vessel:IncrementColor( increment )
    local startId = self.colorId
    local id = startId + increment
    local newColorId = id
    local found = false
    while not found and id ~= startId do
        if id > table.getn( self.ammoPerColor ) then
            id = 1
        end
        if id < 1 then
            id = table.getn( self.ammoPerColor )
        end
        
        if  self.ammoPerColor[ id ] ~= 0 and BubbleClass.static.BubbleColors[ id ].name ~= "Special" then
            newColorId = id
            found = true
        end
        id = id + increment
    end
    
    if not found then
        newColorId = BubbleClass.static.GetColorByName( "Special" )
    end
    
    self:SetColor( newColorId )

end

function Vessel:NextColor(  )
    self:IncrementColor( 1 )   
end

function Vessel:PrevColor(  )
    self:IncrementColor( -1 )   
end

function Vessel:Fire()
    if not self.bubble or not self.bubble.ready then
        return
    end
    local sx, sy = self.body:getLinearVelocity( )

     local mx, my = GetMousePosition( )
     local x = mx - self.body:getX()
    local y = my - self.body:getY()
         
    local x2, y2 = Normalize( x, y )

    local f = 40
  
    self.bubble.body:applyImpulse(  x2 * f,  y2 * f,self.body:getX()   , self.body:getY())
    -- self.bubble:RemoveAllLinks()
    self:ReleaseBubble()
    self.creationTime = love.timer.getTime( )
end

function Vessel:Update(dt)
    if not self.bubble then
        self:CreateBubble()
    end
    if self.bubble then
        self.bubble:Update(dt)
    end
   
    -- self.super:Update()
    if self.realDestroyed == true then
  
        self.realDestroyed = false
        self.destroyed = false
        self.creationTime = love.timer.getTime( )
    end
    

    self.body:applyForce(self.engineForce.x, self.engineForce.y)

    self.particleSystem:setPosition( self.body:getX(), self.body:getY() )
    if self.engineForce.x == 0 and self.engineForce.y == 0 then
        self.particleSystem:pause()
    else
        self.particleSystem:start()
        self.particleSystem:setDirection( VectToRad( -self.engineForce.x, -self.engineForce.y ) )
    end

    
    self.particleSystem:update(dt)
       
     
end

function Vessel:Fire2()
    -- self.bubble:RemoveAllLinks( )
    -- self:CreateBubble()
    self:ReleaseBubble()
end
function Vessel:ResetEngineForce( x, y )
    self.engineForce = 
    { 
        x = 0,
        y = 0
    }
    self.engineForce.x =  0
    self.engineForce.y = 0
end

function Vessel:AddEngineForce( x, y )
    self.engineForce.x =   self.engineForce.x + x 
    self.engineForce.y =   self.engineForce.y + y 
end

function Vessel:Draw()
    if self.bubble then
        self.bubble:Draw( )
    end
    love.graphics.draw(  self.particleSystem )
    
 
    love.graphics.setColor(  BubbleClass.static.BubbleColors[ self.colorId ].rgba ) 
    local x, y = GetMousePosition()
    local xn, yn = Normalize( x - V.body:getX(), y - V.body:getY() )
    local x1 = V.body:getX() + xn *  self.Radius
    local y1 = V.body:getY() + yn *  self.Radius
    
    local xn2, yn2 = Rotate( xn, yn , 2.5 )
    local x2 = V.body:getX() + xn2 *  self.Radius
    local y2 = V.body:getY() + yn2 *  self.Radius
    
    local xn3, yn3 = Rotate( xn, yn , -2.5 )
    local x3 = V.body:getX() + xn3 *  self.Radius
    local y3 = V.body:getY() + yn3 *  self.Radius

    
    love.graphics.setLineStipple( 0x0F0F, 1 )

    
    love.graphics.line( V.body:getX(),V.body:getY(),  V.body:getX() + xn *  self.Radius * 10,
                        V.body:getY() + yn *  self.Radius * 10)
    love.graphics.polygon( 'fill', x1,y1, x2,y2 ,x3,y3)
    
    love.graphics.setColor( 255,255,255,255 ) 
	love.graphics.print( self.ammoPerColor[ self.colorId ],  self.body:getX() - 5, self.body:getY() - 5,0, 0.8,0.8 )

    love.graphics.setColor( 255,255,255,255 ) 

    local ammoTxt = ""
    for cName, ammo in pairs( self.ammoPerColor ) do 
      ammoTxt = ammoTxt .. cName .."[" .. ammo .."] - " 
    end
    love.graphics.print(ammoTxt,20,15)
end


function Vessel:NotifyCollide( obj )

end
 
 
function Vessel:ConsumeAmmo()
   if not self.destroyed then
        self.ammoPerColor[ self.colorId ] = self.ammoPerColor[ self.colorId ] - 1
    end
end

function Vessel:AddAmmo( colorId )
   if not self.destroyed then
        self.ammoPerColor[ colorId ] = self.ammoPerColor[ colorId ] + 1
    end
end


function Vessel:Destroy()
    if not self.destroyed then
        self:ConsumeAmmo( )
        self.destroyed = true
        self.destroyTime = love.timer.getTime()
        self:RemoveAllLinks( )
    end
end



-- function Vessel:OnTarget()
    -- self:Destroy()
    -- return
-- end



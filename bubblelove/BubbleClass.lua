require( "YaciCode" )

DRAW_JOINTS = true

bubbleId = 0
nbLink = 0




BubbleClass = class("BubbleClass")
BubbleClass:setDefaultVirtual(true)


BubbleClass.BubbleColors = 
{
    {
        name = "Red",
        rgba = { 255,0, 0, 255 },
    },
    {
        name = "Blue",
        rgba  = { 0,0, 255, 255 },
    },
    {
        name = "Green",
        rgba  = { 0,255, 0, 255 },
    },
    {
        name = "Yellow",
        rgba  = { 255,255, 0, 255 },
    },
    {
        name = "Purple",
        rgba  = { 255,0, 255, 255 },
    },
    {
        name = "Cyan",
        rgba  = { 0,255, 255, 255 },
    },
    {
        name = "Special",
        rgba  = { 255,255, 255, 255 },
    },
}
function BubbleClass.GetColorByName( name )
    for cId, color in pairs( BubbleClass.static.BubbleColors ) do
        if color.name == name then
            return cId, color
        end
    end
    return nil
end


BubbleClass.Radius = 10
BubbleClass.Mass = 50
function BubbleClass:init( level, x, y, color, mass )
    self.id = bubbleId
    bubbleId = bubbleId + 1
	if mass then
		self.Mass = mass
	end
    self.body = love.physics.newBody( level.world, x, y , self.Mass, 0 )
    self.body:setAngularVelocity( 0 )
    self.body:setLinearDamping( 0.2 ) 
    self.body:setBullet( true )
    self:CreateShape() 
    self.name = "Bubble"

    self.bubble = true --todo change

    self.jointBubbles = {}
    self.joints = {}
    self.destroyed = false
    self:SetColor( color )
    self.spawnTime = love.timer.getMicroTime( )
    self.ready = false
    self.collideSomething = false
    self.frameWithoutColliding = 0
    self.destroyingDuration = 0.1
	self.creatingDuration = 0.05
    self.destroyTime = love.timer.getTime( )
    self.maxCriticTime = 0.2
    self.scale = 1

    return b
end

function BubbleClass:CreateShape( ) 
    self.shape = love.physics.newCircleShape(self.body, 0, 0, self.Radius )
    self.shape:setSensor( true )
    self.shape:setRestitution( 1 )
    self.shape:setData( self )
    self.shape:setFriction( 0 )
    --world:update(0)
    self.shape:setMask(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16)
    -- world:update(0)
    self.shape:setMask( 16 )
    self.shape:setCategory( 1 )
    -- world:update(0)
   -- shapes[1]:setRestitution( 1 )

end

function BubbleClass:SetMass( m )
    self.body:setMass( self.body:getX(), self.body:getY(), m, 0 )
end

function BubbleClass:SetColor( colorId )
    self.colorId = colorId   
    self.color = BubbleClass.static.BubbleColors[ colorId ]
    -- self:StartCheckDestroy()
end



function BubbleClass:Update(dt)

    --Check wether ready or not. A not ready bubble taht collide somthing is destroyed
	if not self.ready and not  self.destroyed then
	 	self.shape:setSensor( false )
		if self.collideSomething then
            self:Destroy() 
		else
			if ( love.timer.getMicroTime( ) - self.spawnTime ) >= self.creatingDuration then
				self.ready = true
			end
		end
	end
    
    -- Check if destroying state ended
	local dt = love.timer.getTime( ) - self.destroyTime
    if  self.destroyed and (love.timer.getTime( ) - self.destroyTime) > self.destroyingDuration then
        self.realDestroyed = true
    end
    
    -- Scale is 1 in normale state, but change at creating/destorying times
    self.scale = 1
	if not self.ready then
	  	self.scale =  ( love.timer.getMicroTime( ) - self.spawnTime ) / self.creatingDuration
    end
    if self.destroyed and not self.realDestroyed then 
        self.scale = self.scale *  ( 1 + ( love.timer.getTime( ) - self.destroyTime ) / self.destroyingDuration )
        deb = "scle" .. self.scale .. "dt" .. love.timer.getTime( ) - self.destroyTime  .. "dura" .. self.destroyingDuration
        -- debug.debug()
	end
    
    -- Destory too long joints
    for i, j in pairs( self.joints ) do
        x1, y1, x2, y2 = j.j:getAnchors()
        local sqrlen = (x2-x1) ^2 + (y2-y1) ^2
        if sqrlen > ( self.shape:getRadius() * 2  ) ^ 2  then
            if not j.critic then
                j.critic = true
                j.criticTime = love.timer.getTime( )
            elseif love.timer.getTime( ) - self.maxCriticTime > j.criticTime then
                --Destroy join
                j.j:destroy()
                self.joints[ i ] = nil
                self.jointBubbles[ i ].jointBubbles[ self.id ] = nil 
                self.jointBubbles[ i ] = nil
            end
        else
            j.critic = false
        end
    end

    
    
end

function BubbleClass:GetNbLinks()
	-- TODO: optimize by counting links
	local n = 0

 	for _,_ in pairs( self.jointBubbles ) do 
		n = n +1
	end
	return n
end

function BubbleClass:Draw()
--text = text .. self.color
    if self.realDestroyed then
        return
    end
    

    -- DEBUG =true
    love.graphics.setColor( self.color.rgba ) 
	if DEBUG then
		-- love.graphics.print( self:GetNbLinks(),  self.body:getX(), self.body:getY() )
        -- love.graphics.print(   ( love.timer.getTime( ) - self.destroyTime )  / self.destroyingDuration,  self.body:getX(), self.body:getY() + 10 )
	end
    love.graphics.setLineStipple( 0xFFFF, 1 )
    love.graphics.circle("line", self.body:getX(), self.body:getY(), self.shape:getRadius() * self.scale, 20)
    love.graphics.setColor( self.color.rgba[1],self.color.rgba[2],self.color.rgba[3], 128) 

    love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius()* self.scale, 20)
    if self.body:getMass() == 0 then
        love.graphics.circle("line", self.body:getX(), self.body:getY(), self.shape:getRadius() -2, 5)
    end
 	local critic = false
    DEBUG = false
    if DEBUG and DRAW_JOINTS and self.joints then  
        for _, j in pairs( self.joints ) do
            love.graphics.setLineStipple( 0xFFFF, 1 )
            x1, y1, x2, y2 = j.j:getAnchors()
            if j.critic  then
                love.graphics.setColor(255, 0,0)
                critic = true
   
            else
                love.graphics.setColor(50, 50, 50,20)
            end
            love.graphics.line( x1, y1, x2, y2 )
           
             if j.critic then
                love.graphics.push()
                love.graphics.setColor(255, 250, 250)
                love.graphics.print( math.ceil( self.maxCriticTime - ( love.timer.getTime( ) - j.criticTime ) ),  x2, y2 )
                -- local f =  j.j:getReactionForce( )
                -- if math.abs( f ) > 1000 then
                    -- love.graphics.print(math.ceil(f),  x2, y2 )
                -- end
                love.graphics.pop()
             end
        end
   end
end

function BubbleClass:CheckDestroy( currentNbSame, doDestroy )

    if alreadyChecked[ self.id ] then
        return currentNbSame
    end

    alreadyChecked[ self.id ] = true
    
    for _, b in pairs( self.jointBubbles ) do
        if b.colorId == self.colorId then
            currentNbSame = b:CheckDestroy( currentNbSame , doDestroy )
        end
    end

    if doDestroy then
        self:Destroy()
    end
    
    return currentNbSame + 1
end
BubbleClass:virtual( "CheckDestroy" )


function BubbleClass:StartCheckDestroy()
    --TODO : wait a bit so the bubble is stabilized

    alreadyChecked = {}
    nb = self:CheckDestroy( 0 , false)
    love.graphics.printf( "-" .. nb, 70, 70, love.graphics.getWidth() - 70)
    if nb >= 3 then
        --debug.debug()
            alreadyChecked = {}
            self:CheckDestroy( 1 , true )
    end
end
BubbleClass:virtual( "StartCheckDestroy" )


function BubbleClass:NotifyCollide( obj )
    if obj.name == "Vessel" then
        return
    end
    self.collideSomething = true
    
end

function BubbleClass:Join( withBubble, createJoin )
    if self.destroyed or withBubble.destroyed then
        return
    end

    if not self.ready or not withBubble.ready then
        return
    end
   

    if self:GetNbLinks() > 6 then
        return
    end
    
    --Already joint
    if self.jointBubbles[ withBubble.id ] then 
        return 
    end

    if createJoin then
        local joint = love.physics.newDistanceJoint( self.body, withBubble.body, self.body:getX() , self.body:getY(), withBubble.body:getX(), withBubble.body:getY() )
        joint:setCollideConnected( true )
        -- joint:setFrequency( 60 )
        -- joint:setDamping( 1 )

        joint:setLength( self.shape:getRadius() + withBubble.shape:getRadius() - 1  )
        withBubble:Join( self, false )
        self.joints[ withBubble.id ] = 
        { 
            j = joint , 
            critic = false,
            criticTime = nil,
        }
        nbLink = nbLink + 1
    end
    self.jointBubbles[ withBubble.id ] =  withBubble

	if not DONNOTDESTROY then
        if withBubble.colorId == self.colorId then
            self:StartCheckDestroy()
        end
    end

end


function BubbleClass:RemoveLinkWith( bubbleId )
    if self.joints[ bubbleId ] then
        self.joints[ bubbleId ].j:destroy()
        self.joints[ bubbleId ] = nil
    end

    if self.jointBubbles[ bubbleId ] then
        self.jointBubbles[ bubbleId ] = nil;
    end
end

function BubbleClass:RemoveAllLinks(  )
    for _, b in pairs( self.jointBubbles ) do
        b:RemoveLinkWith( self.id )
        self:RemoveLinkWith( b.id )
    end
end

function BubbleClass:Destroy()

    self.destroyed = true
    if self.onDestroyCallback then
        self.onDestroyCallback.f(self.onDestroyCallback.p, self.ready)
    end
    self.shape:setMask(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16)
    self.destroyTime = love.timer.getTime( )
    self:RemoveAllLinks()
	local vx , vy = self.body:getLinearVelocity( )
    self.body:setLinearVelocity( vx / 10 , vy / 10 )
   --self:SetMass( -self.Mass )
    
end
BubbleClass:virtual( "Destroy" )

function BubbleClass:RealDestroy()
    if self.destroyed then
        self.shape:destroy()
        self.body:destroy()
    end
end

function BubbleClass:OnTarget()
    self:Destroy()
end
----------------------------------------------------------------------------------------------------

bubbleId = 0
nbLink = 0
local BubbleColors = 
{
    Red = 
    {
        rgba = { 255,0, 0, 255 },
    },
    Blue = 
    {
        rgba  = { 0,0, 255, 255 },
    },
    Green = 
    {
        rgba  = { 0,255, 0, 255 },
    }
}

BubbleClass = {}

function BubbleClass.new( x, y, color )
    local b = {}
    setmetatable(b, {__index=BubbleClass})
    local mass = 50
    local radius = 5
    b.body = love.physics.newBody(world, x, y , mass, 0)
    b.body:setLinearDamping( 0.2 ) 
    b.shape = love.physics.newCircleShape(b.body, 0, 0, radius)
    b.shape:setRestitution( 1 )
    b.shape:setData( b )
    b.name = "Bubble"
    b:SetColor( color )

    b.bubble = true --todo change
    b.id = bubbleId
    bubbleId = bubbleId + 1
    b.jointBubbles = {}
    b.joints = {}
    b.destroyed = false
    return b
end

function BubbleClass:SetColor( color )
    self.colorName = color   
    self.color = BubbleColors[ color ]
end

function BubbleClass:Draw()
--text = text .. self.color
    if self.destroyed then
        return
    end
    
    love.graphics.setColor( self.color.rgba ) 
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius(), 20)
    if DRAW_JOINTS and self.joints then  
        for _, j in pairs( self.joints ) do
           love.graphics.setColor(0, 0, 0)
           x1, y1, x2, y2 = j:getAnchors()
           love.graphics.line( x1, y1, x2, y2 )
        end
   end
end


function BubbleClass:Fire()
    local sx, sy = self.body:getLinearVelocity( )

     local mx, my = love.mouse.getPosition( )
     local x = mx - self.body:getX()
    local y = my - self.body:getY()
         
    local x2, y2 = Normalize( x, y )
    local b =   BubbleClass.new( self.body:getX() + x2 * self.shape:getRadius() * 2.5   , self.body:getY() +  y2 * self.shape:getRadius() * 2.5  , self.colorName )
   -- local b =   BubbleClass.new( self.body:getX()   , self.body:getY()   , "Green" )
    local speed = 400
    b.body:setLinearVelocity( sx + x2 * speed, sy + y2 * speed)
    table.insert( objects,b )
end

function BubbleClass:CheckDestroy( currentNbSame, doDestroy )
    if alreadyChecked[ self.id ] then
        return currentNbSame
    end

    alreadyChecked[ self.id ] = true
    
    for _, b in pairs( self.jointBubbles ) do
        if b.colorName == self.colorName then
            currentNbSame = b:CheckDestroy( currentNbSame , doDestroy )
        end
    end

    if doDestroy then
        self:Destroy()
    end
    
    return currentNbSame + 1
end

function BubbleClass:DestroyAllJoints()
    for _, j in pairs( self.joints ) do
       -- j:destroy()
    end
end


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

function BubbleClass:Join( withBubble, createJoin )
    if self.destroyed then
        return
    end
    
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
        joint:setLength( self.shape:getRadius() + withBubble.shape:getRadius()  )
        withBubble:Join( self, false )
        self.joints[ withBubble.id ] = joint
        nbLink = nbLink + 1
    end
    self.jointBubbles[ withBubble.id ] =  withBubble
    self:StartCheckDestroy()
end

function BubbleClass:removeLinkWith( bubbleId )
    if self.joints[ bubbleId ] then
        self.joints[ bubbleId ]:destroy()
        self.joints[ bubbleId ] = nil
    end

    if self.jointBubbles[ bubbleId ] then
        self.jointBubbles[ bubbleId ] = nil;
    end
end

function BubbleClass:Destroy()
    self.destroyed = true
    self.shape:setMask(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16)

    for _, b in pairs( self.jointBubbles ) do
        b:removeLinkWith( self.id )
        self:removeLinkWith( b.id )
    end

end

function BubbleClass:RealDestroy()
    if self.destroyed then
        --self.shape:destroy()
        --self.body:destroy()
    end
end
----------------------------------------------------------------------------------------------------
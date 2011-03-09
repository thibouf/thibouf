require( "YaciCode" )

DRAW_JOINTS = false

bubbleId = 0
nbLink = 0


BubbleClass = newclass("BubbleClass")

BubbleClass.BubbleColors = 
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
    },
    White = 
    {
        rgba  = { 255,255, 255, 255 },
    },
}


BubbleClass.Radius = 10
BubbleClass.Mass = 50

function BubbleClass:init( x, y, color )
    self.id = bubbleId
    bubbleId = bubbleId + 1
    self.body = love.physics.newBody( world, x, y , self.Mass, 0 )
    self.body:setAngularVelocity( 0 )
    --self.body:setLinearDamping( 0.2 ) 
    self:CreateShape() 
    self.name = "Bubble"

    self.bubble = true --todo change

    self.jointBubbles = {}
    self.joints = {}
    self.destroyed = false
    self:SetColor( color )

    return b
end

function BubbleClass:CreateShape( ) 
    self.shape = love.physics.newCircleShape(self.body, 0, 0, self.Radius )
    self.shape:setRestitution( 1 )
    self.shape:setData( self )
end

function BubbleClass:SetColor( color )
    self.colorName = color   
    self.color = self.BubbleColors[ color ]
    self:StartCheckDestroy()
end

function BubbleClass:NextColor( )
    local k, c = next( self.BubbleColors, self.colorName )
    if k == nil then
        k, c = next( self.BubbleColors )
    end
    self.colorName = k   
    self.color = c
    self:StartCheckDestroy()
end

function BubbleClass:Draw()
--text = text .. self.color
    if self.destroyed then
        return
    end
    
    love.graphics.setColor( self.color.rgba ) 
    love.graphics.setLineStipple( 0xFFFF, 1 )
    love.graphics.circle("line", self.body:getX(), self.body:getY(), self.shape:getRadius(), 20)
    if DRAW_JOINTS and self.joints then  
        for _, j in pairs( self.joints ) do
           love.graphics.setColor(0, 0, 0)
           x1, y1, x2, y2 = j:getAnchors()
           love.graphics.line( x1, y1, x2, y2 )
        end
   end
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
BubbleClass:virtual( "CheckDestroy" )

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
BubbleClass:virtual( "StartCheckDestroy" )


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
        joint:setLength( self.shape:getRadius() + withBubble.shape:getRadius() + 1  )
        withBubble:Join( self, false )
        self.joints[ withBubble.id ] = joint
        nbLink = nbLink + 1
    end
    self.jointBubbles[ withBubble.id ] =  withBubble
    self:StartCheckDestroy()
end



function BubbleClass:RemoveLinkWith( bubbleId )
    if self.joints[ bubbleId ] then
        self.joints[ bubbleId ]:destroy()
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
    self.shape:setMask(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16)

    self:RemoveAllLinks()
end
BubbleClass:virtual( "Destroy" )

function BubbleClass:RealDestroy()
    if self.destroyed then
        --self.shape:destroy()
        --self.body:destroy()
    end
end
----------------------------------------------------------------------------------------------------
require( "BubbleClass" )
require( "Math" )

Vessel = BubbleClass:subclass( "Vessel" )


function Vessel:init( x, y, color )
    self.Radius = 12
    self.Mass = 500
    self.super:init( x, y, color )
end

function Vessel:Fire()
    local sx, sy = self.body:getLinearVelocity( )

     local mx, my = love.mouse.getPosition( )
     local x = mx - self.body:getX()
    local y = my - self.body:getY()
         
    local x2, y2 = Normalize( x, y )
    local b =   BubbleClass:new( self.body:getX() + x2 * self.shape:getRadius() * 2.5   , self.body:getY() +  y2 * self.shape:getRadius() * 2.5  , self.colorName )
   -- local b =   BubbleClass.new( self.body:getX()   , self.body:getY()   , "Green" )
    local speed = 400
    b.body:setLinearVelocity( sx + x2 * speed, sy + y2 * speed)
    table.insert( objects,b )
end

function Vessel:Fire2()
    self:RemoveAllLinks( )
end

function Vessel:Draw()
    self.super:Draw( )
    love.graphics.setColor( 0,0,0,255 ) 
   -- love.graphics.circle( "fill", self.body:getX(), self.body:getY(), self.shape:getRadius() - 1, 20 )
    
    love.graphics.setColor( 0,0,0,255 ) 
    local x, y = love.mouse.getPosition( )
    local xn, yn = Normalize( x - V.body:getX(), y - V.body:getY() )
    local x1 = V.body:getX() + xn *  self.shape:getRadius()
    local y1 = V.body:getY() + yn *  self.shape:getRadius()
    
    local xn2, yn2 = Rotate( xn, yn , 2.5 )
    local x2 = V.body:getX() + xn2 *  self.shape:getRadius()
    local y2 = V.body:getY() + yn2 *  self.shape:getRadius()
    
    local xn3, yn3 = Rotate( xn, yn , -2.5 )
    local x3 = V.body:getX() + xn3 *  self.shape:getRadius()
    local y3 = V.body:getY() + yn3 *  self.shape:getRadius()

    
    love.graphics.setLineStipple( 0x0F0F, 1 )

    
    --love.graphics.line( V.body:getX(),V.body:getY(),x1, y1)
    love.graphics.line( V.body:getX(),V.body:getY(),  V.body:getX() + xn *  self.shape:getRadius() * 10,
                        V.body:getY() + yn *  self.shape:getRadius() * 10)
    love.graphics.polygon( 'fill', x1,y1, x2,y2 ,x3,y3)
end


-- Vessel can not be destroyed by bubbles
--function Vessel:CheckDestroy( currentNbSame, doDestroy )
--    return currentNbSame
--end
--function Vessel:StartCheckDestroy()
--    return
--end

function Vessel:Destroy()
    self:RemoveAllLinks( )
    return
end
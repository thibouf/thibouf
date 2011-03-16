require( "BubbleClass" )
require( "Math" )

Vessel = BubbleClass:subclass( "Vessel" )


function Vessel:init( x, y, color )
    self.Radius = 12
    self.Mass = 300
    self.super:init( x, y, color )
    
    self.image = love.graphics.newImage( "test.png" )
    self.particleSystem = love.graphics.newParticleSystem( self.image, 100 )

   self.particleSystem:setEmissionRate(100)
    self.particleSystem:setSpeed(300, 400)
    self.particleSystem:setGravity(0)
    self.particleSystem:setSize(1, 1,1)
    self.particleSystem:setColor(255, 255, 255, 255, 58, 128, 255, 0)
    self.particleSystem:setPosition(400, 300)
    self.particleSystem:setLifetime(-1)
    self.particleSystem:setParticleLife(0.3)
    self.particleSystem:setDirection(0)
    self.particleSystem:setSpread(0.5)
    self.particleSystem:setSpin(0,1,1)

    self.particleSystem:start()
    
end

function Vessel:Fire()
   
    local sx, sy = self.body:getLinearVelocity( )

     local mx, my = love.mouse.getPosition( )
     local x = mx - self.body:getX()
    local y = my - self.body:getY()
         
    local x2, y2 = Normalize( x, y )
    local b =   BubbleClass:new( self.body:getX() + x2 * ( self.shape:getRadius() + 11 )   , self.body:getY() +  y2 * ( self.shape:getRadius() + 11 )  , self.colorName )
   -- local b =   BubbleClass.new( self.body:getX()   , self.body:getY()   , "Green" )
    local speed = 600
   -- b.body:setLinearVelocity( sx + x2 * speed, sy + y2 * speed)
    b.body:setLinearVelocity(  x2 * speed,  y2 * speed)
    table.insert( objects,b )
    --b.shape:setSensor( true )
end

function Vessel:Update(dt)
    self.super:Update( )
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
    self:RemoveAllLinks( )
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
    self.super:Draw( )

    love.graphics.draw(  self.particleSystem )
    
    love.graphics.setColor( 0,100,0,255 ) 
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
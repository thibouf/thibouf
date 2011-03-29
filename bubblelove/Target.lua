require( "YaciCode" )
require( "BubbleClass" )
Target = class("Target")

function Target:init( level, x, y, width, height, color, vessel )
    self.name = "Target"
    self.width = width
    self.height = height
    self.body = love.physics.newBody( level.world, x, y, 0, 0)
    self.shape = love.physics.newRectangleShape( self.body , 0, 0, width, height, 0 )
    self.shape:setSensor( true )
    self.shape:setData( self )
    self.colorId = color
    self.color = BubbleClass.static.BubbleColors[ color ]
    self.vessel = vessel
end

function Target:Draw()
    love.graphics.setColor(0,255, 0, 255)
    love.graphics.setColor( self.color.rgba[1],self.color.rgba[2],self.color.rgba[3], 50) 
    love.graphics.rectangle("fill", self.body:getX() - self.width/2, self.body:getY() - self.height/2, self.width, self.height)
    love.graphics.setLineStipple( 0x0F0F, 1 )

    love.graphics.setColor( self.color.rgba[1],self.color.rgba[2],self.color.rgba[3], 255) 
    love.graphics.rectangle("line", self.body:getX() - self.width/2, self.body:getY() - self.height/2, self.width, self.height)

end

function Target:NotifyCollide( withBubble )
    
    if withBubble.name == "Bubble" and  ( self.color.name == "Special" or withBubble.colorId == self.colorId) then
        if withBubble.ready then
            if self.vessel then
                self.vessel:AddAmmo( withBubble.colorId )
            end
            withBubble:OnTarget()
        end
        -- self.vessel.ammoPerColor[  withBubble.colorId ] = self.vessel.ammoPerColor[  withBubble.colorId ] + 1
    end
end

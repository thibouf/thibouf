require( "YaciCode" )
require( "BubbleClass" )
Target = class("Target")

function Target:init( x, y, width, height, color, vessel )
    self.name = "Target"
    self.width = width
    self.height = height
    self.body = love.physics.newBody(world, x, y, 0, 0)
    self.shape = love.physics.newRectangleShape( self.body , 0, 0, width, height, 0 )
    self.shape:setSensor( true )
    self.shape:setData( self )
    self.colorName = color
    self.color = BubbleColors[ color ]
    self.vessel = vessel
end

function Target:Draw()
    love.graphics.setColor(0,255, 0, 255)
    love.graphics.setColor( self.color.rgba[1],self.color.rgba[2],self.color.rgba[3], 200) 
    love.graphics.rectangle("fill", self.body:getX() - self.width/2, self.body:getY() - self.height/2, self.width, self.height)

end

function Target:NotifyCollide( withBubble )
    if self.colorName == "Special" or withBubble.colorName == self.colorName then
        self.vessel:AddAmmo( withBubble.colorName )
        withBubble:OnTarget()

        -- self.vessel.ammoPerColor[  withBubble.colorName ] = self.vessel.ammoPerColor[  withBubble.colorName ] + 1
    end
end

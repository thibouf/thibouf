
WallClass = {}

function WallClass.new( level, x, y, width, height)
    local w = {}
    setmetatable(w, {__index=WallClass})
    w.width = width
    w.height = height
    w.body = love.physics.newBody( level.world, x, y, 0, 0)
    w.shape = love.physics.newRectangleShape( w.body, 0, 0, width, height, 0 )
    w.shape:setData( w )
    w.name = "Wall"
    return w
end

function WallClass:Draw()
    love.graphics.setColor(0,0, 0)
    love.graphics.rectangle("fill", self.body:getX() - self.width/2, self.body:getY() - self.height/2, self.width, self.height)

end
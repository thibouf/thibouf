require( "YaciCode" )

Towel = class("Towel")

Towel.Steps=
{
    [ 1 ] = 
    { 
        intervale = 0.1,
        duration = 1,
        nextStep = 2,
    },
    [ 2 ] = 
    { 
        intervale = 2,
        duration = 10,
        nextStep = 3,
    },
    [ 3 ] = 
    { 
        intervale = 0.1,
        duration = 3,
        nextStep = 4,
    },
    [ 4 ] = 
    { 
        intervale = 50,
        duration = 500000,
        nextStep = 1,
    },
    
}

function Towel:init( x , y, target )
    self.x = x
    self.y = y
    self.target = target
    self.lastFireTime = love.timer.getTime( )
    self.stepId = 1;
    self.step = self.Steps[ self.stepId ]
    self.step.endTime = love.timer.getTime( ) + self.step.duration
    self.bubbleColor = "Blue"
end

function Towel:Draw()
    love.graphics.setColor( 255,255,255,255 ) 
    love.graphics.setLineStipple( 0xFF0F, 1 )
    love.graphics.circle("line", self.x, self.y, 5, 4)
end


function Towel:Update()
    local time = love.timer.getTime( )
    local dt = time - self.lastFireTime

    if time > self.step.endTime then
        self.stepId =  self.step.nextStep 
        self.step = self.Steps [ self.stepId ]
        self.step.endTime = self.step.duration + time
    end
    

    
    if time - self.lastFireTime > self.step.intervale then
        self:Fire()
        self.lastFireTime = time
    end
end


function Towel:Fire()

    local tx =  self.target.body:getX()
    local ty =  self.target.body:getY()
     
    local x = tx - self.x
    local y = ty - self.y
         
    local x2, y2 = Normalize( x, y )
    local b =   BubbleClass:new( self.x + x2 * 1, self.y +  y2 * 1  , self.bubbleColor )
    b:NextColor()
    self.bubbleColor = b.colorName
    
    local speed = 600
    b.body:setLinearVelocity(  x2 * speed,  y2 * speed)
    table.insert( objects,b )
    --b.shape:setSensor( true )
end
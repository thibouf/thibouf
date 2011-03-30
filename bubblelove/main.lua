require( "Level" )
require( "Menu" )

require( "Math" )

text = ""



function InitWorld()
    level = Level:new( "lvl2" ) 
end
----------------------------------------------------------------------------------------------------
function love.load()
	-- InitWorld()
    GotoState( "Menu" )
  --initial graphics setup
  love.graphics.setBackgroundColor(0, 0, 50) 
  love.graphics.setMode(1024, 768, false, true, 0) --set the window dimensions to 650 by 650
end


function love.update(dt)
    text = love.timer.getFPS() .. " - "
  
    state:Update( dt )
end

function love.mousepressed( x, y, button )
  state:MousePressed(  x, y, button )
end


function SaveGame()
	savedGame = {}
  for _, o in pairs( objects ) do
	table.insert( savedGame , o )
  end 
end

function LoadGame()
	InitWorld()
end


function love.keypressed(key, u)
   --Debug
   	if key == "rctrl" then --set to whatever key you want to use
      debug.debug()
   	-- elseif key == "s" then
		-- SaveGame()

	end
    
    state:KeyPressed( key, u )
    
end


function GetMousePosition()
	 local x, y = love.mouse.getPosition( )
	return x - diffX, y - diffY 
end

function love.draw()
    state:Draw()
    love.graphics.setColor( 0,0,0,255 ) 
  -- love.graphics.print(text,0,12) 
end

StateList = 
{
    Menu = 
    { 
        init = function( params ) return Menu:new() end,
    },
    Game = 
    {   
        init = function( params ) return Level:new( params[1] ) end,
    }
}

function GotoState( stateName, params )
    print( stateName.. tostring( state ) )
    local st = StateList[ stateName ]
    local stateInit = st.init
    state = stateInit(params) 

end

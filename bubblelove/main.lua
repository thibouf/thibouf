require( "Level" )

require( "Math" )

text = ""



function InitWorld()
    level = Level:new( "lvl2" ) 
end
----------------------------------------------------------------------------------------------------
function love.load()
	InitWorld()
  
  --initial graphics setup
  love.graphics.setBackgroundColor(0, 0, 50) 
  love.graphics.setMode(1024, 768, false, true, 0) --set the window dimensions to 650 by 650
end


function love.update(dt)
    text = love.timer.getFPS() .. " - "
  
    level:Update( dt )
end

function love.mousepressed( x, y, button )
  level:MousePressed(  x, y, button )
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
	elseif key == "l" then
		LoadGame()
	end
end


function GetMousePosition()
	 local x, y = love.mouse.getPosition( )
	return x - diffX, y - diffY 
end

function love.draw()
    level:Draw()
    love.graphics.setColor( 0,0,0,255 ) 
  -- love.graphics.print(text,0,12)
  
 
  
end

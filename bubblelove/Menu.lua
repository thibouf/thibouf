require( "YaciCode" )

Menu = class("Menu")

Menu.Items =
{
    {
        text = "Start 1",
        action = function() GotoState( "Game", { "lvl1" } ) end
    },
    {
        text = "Start 2",
        action = function() GotoState( "Game", { "lvl2" } ) end
    },
    {
        text = "Quit",
        action = function() os.exit(0)  end
    }
}


function Menu:init( )
    selectedItem =  1
end


function Menu:Update( dt )


end

function Menu:Draw()
    for i, item in pairs( self.Items ) do
        if i == selectedItem then
            love.graphics.setColor( 0,255,0,255 ) 
        else
            love.graphics.setColor( 255,0,0,255 ) 
        end
        love.graphics.print( item.text, 10, 10 * i, 0, 2 ,2  )
    end
end

function Menu:MousePressed( x, y, button )

end
function Menu:KeyPressed( key, u )
    print( key )
   --Debug
   	if key == "down" then --set to whatever key you want to use
        selectedItem = selectedItem + 1
        if selectedItem > #self.Items then
            selectedItem = 1
        end
 	elseif key == "up" then
        selectedItem = selectedItem - 1
        if selectedItem < 1 then
            selectedItem = #self.Items
        end
    elseif key == "return" then
        local func =  self.Items[selectedItem].action
        func()
    
	end
end
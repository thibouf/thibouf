local X = 1024
local Y = 768

local TowerSteps=
{
    [ 1 ] = 
    { 
        intervale = 0.1,
        duration = 2,
        nextStep = 2,
    },
    [ 2 ] = 
    { 
        intervale = 1,
        duration = 100,
        nextStep = 1,
    },
}


local Level =
{
	{
        T = "Bubble",
		x = X / 2,
		y = 50,
		color = "Special",
		mass = 0,
	},
    {
		T = "Bubble",
		x = X / 2 + 20,
		y = 50,
		color = "Special",
		mass = 0,
	},
    {
		T = "Bubble",
		x = X / 2 - 20,
		y = 50,
		color = "Special",
		mass = 0,
	},
	{
		T = "Vessel",
		x = X / 2,
		y = Y - 100,
		color = "Special",
	},
	-- {
		-- T = "Tower",
		-- x = 60,
		-- y = 100,
		-- target = 2,
        -- steps = TowerSteps,
        -- force = 800,
	-- },
    {
		T = "Target",
		x = X / 2,
		y = Y-50,
        h = 50,
		w = X,
        color = "Special"
	}, 
	{
		T = "Wall",
		x = X/2,
		y = Y,
		h = 50,
		w = X,
	},
	{
		T = "Wall",
		x = X/2,
		y = 0,
		h = 50,
		w = X,
	},
	{
		T = "Wall",
		x = 0,
		y = Y/2,
		h = Y,
		w = 500,
	},
	{
		T = "Wall",
		x = X,
		y = Y/2,
		h = Y,
		w = 500,
	},
	{
		T = "Bubble",
		x = X / 2 + 10 ,
		y = 50,
		color = "Red",
	},	 
    {
		T = "Bubble",
		x = X / 2  - 10 ,
		y = 50,
		color = "Red",
	},	 
    {
		T = "Bubble",
		x = X / 2  - 20 ,
		y = 80,
		color = "Blue",
	},	
    {
		T = "Bubble",
		x = X / 2  + 20 ,
		y = 80,
		color = "Blue",
	},	
    {
		T = "Bubble",
		x = X / 2  ,
		y = 80,
		color = "Blue",
	},	
        {
		T = "Bubble",
		x = X / 2  - 10 ,
		y = 95,
		color = "Green",
	},	
    {
		T = "Bubble",
		x = X / 2  + 30 ,
		y = 95,
		color = "Green",
	},	
    {
		T = "Bubble",
		x = X / 2 + 10 ,
		y = 95,
		color = "Green",
	},	
    {
		T = "Bubble",
		x = X / 2 - 30 ,
		y = 95,
		color = "Green",
	},	
	
}
return Level

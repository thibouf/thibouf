local X = 1024
local Y = 768

local Level =
{
	 
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
		w = 50,
	},
	{
		T = "Wall",
		x = X,
		y = Y/2,
		h = Y,
		w = 50,
	},
	{
		T = "Bubble",
		x = X / 2 + 10,
		y = 100,
		color = "Special",
		mass = 0,
	},
    	{
		T = "Bubble",
		x = X / 2 - 10,
		y = 50,
		color = "Special",
		mass = 0,
	},
	{
		T = "Bubble",
		x = X / 2 ,
		y = 50,
		color = "Red",
	},	 
	{
		T = "Bubble",
		x = 650/2,
		y = 110,
		color = "Red",
	},	
	{
		T = "Bubble",
		x = 650/2 + 10,
		y = 110,
		color = "Red",
	},	
	{
		T = "Vessel",
		x = X / 2,
		y = Y - 100,
		color = "Special",
	},
	{
		T = "Tower",
		x = 60,
		y = 60,
		target = 5,
	},
    {
		T = "Target",
		x = X / 2,
		y = Y-50,
        h = 50,
		w = X,
        color = "Special"
	}
}
return Level

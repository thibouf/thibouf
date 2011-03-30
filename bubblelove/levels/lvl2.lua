local X = 1024
local Y = 768


local Level =
{
	{
		T = "Vessel",
		x = X / 2,
		y = Y - 150,
		color = "Special",
	},
    {
		T = "Target",
		x = X / 2,
		y = Y-25,
        h = 50,
		w = X,
        color = "Special"
	}, 
    {
		T = "Target",
		x = X / 2,
		y = Y-100,
        h = 25,
		w = X,
        color = "Red"
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
		T = "Wall",
		x = X/2,
		y = Y,
		h = 300,
		w = 50,
	},
	{
		T = "RandomZone",
        x = X / 4,
        y = "10",
        nx = "10",
        ny = "10",
    },
    {
		T = "RandomZone",
        x = X / 4 + 220,
        y = "10",
        nx = "10",
        ny = "10",
    }
	
}
return Level

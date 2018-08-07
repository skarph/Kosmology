LEVEL = {};

LEVEL.currentLevel = nil;

function LEVEL.load(string)
	LEVEL.currentLevel = string;
	local data = JSON.decode(string);-->> creates a new ball relative to center with the provided json string
	
	for i,v in ipairs(data) do
		n = BALL.new(data[i].pos.x,data[i].pos.y,
		data[i].rad,data[i].mass,
		{data[i].color[1],data[i].color[2],data[i].color[3],data[i].color[4]}
		,data[i].lock,data[i].img or ASSET.sprites.planet);
		
		BALL.list[n].vel = V.vectorize({data[i].vel.x,data[i].vel.y});--give velocity to the ball
	end

end

function LEVEL.unload()-->> unloads data
	
	for i=1,BALL.lastIndex do
		BALL.list[i] = nil;
		GTIME = 0;
	end
	
	LEVEL.currentLevel = nil;
	BALL.lastIndex = 1;
end
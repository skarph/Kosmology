GAMEMNG = {}
GAMEMNG.RESET = false;
GAMEMNG.WINTIME = 15;
GAMEMNG.OVERFADE = 0;
GAMEMNG.POWLIST = {"gun","gshot","boom","drill","flag"}
GAMEMNG.SPRITELIST = {gun = "gun",gshot = "gshot",boom = "bigthrust",drill = "drill0",flag="flag"};
GAMEMNG.FLAG = false;
GAMEMNG.NEXTPOW = 1;
GAMEMNG.POWCOUNT = 0;
GAMEMNG.PSTATE = {
	{--Player 1
		gun = 0,
		power = "",
		flag = false,
		flagt = 0.0,
		boost = false,
		htime = 0.0,
		drtime = 0.0,
		bullets = 0;
		score = 0;
	},
	{--Player 2
		gun = 0,
		power = "",
		flag = false,
		flagt = 0.0,
		boost = false,
		htime = 0.0,
		drtime = 0.0,
		bullets = 0;
		score = 0;
	}
}

--[[
Powerups:
Gun
Wings
-----
Hookshot
Drill
Bomb

]]
function GAMEMNG.updateStat(dt)
	GAMEMNG.PSTATE[1].boost = false;
	GAMEMNG.PSTATE[2].boost = false;
	CONSOLE.VALS.fT = "{1}: "..GAMEMNG.PSTATE[1].flagt.."{2}: "..GAMEMNG.PSTATE[2].flagt;
	CONSOLE.VALS.Score = "{1}: "..GAMEMNG.PSTATE[1].score.."{2}: "..GAMEMNG.PSTATE[2].score;
	--gshot
	if(GAMEMNG.PSTATE[1].htime>0) then
		BALL.list[1].seek = 2;
		GAMEMNG.PSTATE[1].htime = GAMEMNG.PSTATE[1].htime - dt;
	else
		GAMEMNG.PSTATE[1].htime = 0;
		BALL.list[1].seek = nil;
	end

	if(GAMEMNG.PSTATE[2].htime>0) then
		BALL.list[2].seek = 1;
		GAMEMNG.PSTATE[2].htime = GAMEMNG.PSTATE[2].htime - dt;
	else
		GAMEMNG.PSTATE[2].htime = 0;
		BALL.list[2].seek = nil;
	end
	--drill
	if(GAMEMNG.PSTATE[1].drtime>0) then
		BALL.list[1].vel = V.vectorize({math.cos(BALL.list[1].dir),math.sin(BALL.list[1].dir)})*300;
		BALL.list[1].iFrames = 1;
		GAMEMNG.PSTATE[1].drtime = GAMEMNG.PSTATE[1].drtime - dt;
	else
		BALL.list[1].iFrames = 0;
		GAMEMNG.PSTATE[1].drtime = 0;
	end

	if(GAMEMNG.PSTATE[2].drtime>0) then
		BALL.list[2].vel = V.vectorize({math.cos(BALL.list[2].dir),math.sin(BALL.list[2].dir)})*300;
		BALL.list[2].iFrames = 1;
		GAMEMNG.PSTATE[2].drtime =  GAMEMNG.PSTATE[2].drtime - dt;
	else
		BALL.list[2].iFrames = 0;
		GAMEMNG.PSTATE[2].drtime = 0;
	end
	--flag
	if(GAMEMNG.PSTATE[1].power == "flag") then
		GAMEMNG.PSTATE[1].flagt = GAMEMNG.PSTATE[1].flagt + dt;
	end
	if(GAMEMNG.PSTATE[2].power == "flag") then
		GAMEMNG.PSTATE[2].flagt = GAMEMNG.PSTATE[2].flagt + dt;
	end

	if(GAMEMNG.PSTATE[1].flagt > GAMEMNG.WINTIME) then
		GAMEMNG.PSTATE[1].flagt = 0.0;
		GAMEMNG.PSTATE[1].score = GAMEMNG.PSTATE[1].score + 1;
		GAMEMNG.RESET = true;
		GAMEMNG.FLAG = false;
		for i=1, #GAMEMNG.PSTATE do
			GAMEMNG.PSTATE[i].gun = 0;
			GAMEMNG.PSTATE[i].power = "";
			GAMEMNG.PSTATE[i].flag = false;
			GAMEMNG.PSTATE[i].flagt = 0.0;
			GAMEMNG.PSTATE[i].boost = false;
			GAMEMNG.PSTATE[1].flagt = 0.0;
			GAMEMNG.PSTATE[1].score = GAMEMNG.PSTATE[1].score + 1;
			GAMEMNG.PSTATE[i].htime = 0.0;
			GAMEMNG.PSTATE[i].drtime = 0.0;
			GAMEMNG.PSTATE[i].bullets = 0;
		end
		GAMEMNG.POWCOUNT = 0;
		LEVEL.unload()
		LEVEL.load(ASSET.levels.example);
		--resetGame
	else
		GAMEMNG.RESET = false;
	end

	if(GAMEMNG.PSTATE[2].flagt > GAMEMNG.WINTIME) then
		GAMEMNG.PSTATE[2].flagt = 0.0;
		GAMEMNG.PSTATE[2].score = GAMEMNG.PSTATE[2].score + 1;
		GAMEMNG.RESET = true;
		GAMEMNG.FLAG = false;
		for i=1, #GAMEMNG.PSTATE do
			GAMEMNG.PSTATE[i].gun = 0;
			GAMEMNG.PSTATE[i].power = "";
			GAMEMNG.PSTATE[i].flag = false;
			GAMEMNG.PSTATE[i].flagt = 0.0;
			GAMEMNG.PSTATE[i].boost = false;
			GAMEMNG.PSTATE[1].flagt = 0.0;
			GAMEMNG.PSTATE[1].score = GAMEMNG.PSTATE[1].score + 1;
			GAMEMNG.PSTATE[i].htime = 0.0;
			GAMEMNG.PSTATE[i].drtime = 0.0;
			GAMEMNG.PSTATE[i].bullets = 0;
		end
		GAMEMNG.POWCOUNT = 0;
		LEVEL.unload()
		LEVEL.load(ASSET.levels.example);
	else
		--resetGame
		GAMEMNG.RESET = false;
	end
	if(GAMEMNG.PSTATE[2].flagt > GAMEMNG.WINTIME) then
		GAMEMNG.PSTATE[2].flagt = 0.0;
		GAMEMNG.PSTATE[2].score = GAMEMNG.PSTATE[2].score + 1;
		GAMEMNG.RESET = true;
		GAMEMNG.FLAG = false;
		for i=1, #GAMEMNG.PSTATE do
			GAMEMNG.PSTATE[i].gun = 0;
			GAMEMNG.PSTATE[i].power = "";
			GAMEMNG.PSTATE[i].flag = false;
			GAMEMNG.PSTATE[i].flagt = 0.0;
			GAMEMNG.PSTATE[i].boost = false;
			GAMEMNG.PSTATE[i].htime = 0.0;
			GAMEMNG.PSTATE[i].drtime = 0.0;
			GAMEMNG.PSTATE[i].bullets = 0;
		end
		GAMEMNG.POWCOUNT = 0;
		LEVEL.unload()
		LEVEL.load(ASSET.levels.example);
		--resetGame
	else
		GAMEMNG.RESET = false;
	end
	if(GAMEMNG.PSTATE[1].power == "gun") then
		GAMEMNG.PSTATE[1].gun = GAMEMNG.PSTATE[1].gun + 1;
		if GAMEMNG.PSTATE[1].gun > 2 then
			GAMEMNG.PSTATE[1].gun = 2; 
		end
		GAMEMNG.PSTATE[1].power = "";
	end
	if(GAMEMNG.PSTATE[2].power == "gun") then
		GAMEMNG.PSTATE[2].gun = GAMEMNG.PSTATE[1].gun + 1;
		if GAMEMNG.PSTATE[2].gun > 2 then
			GAMEMNG.PSTATE[2].gun = 2; 
		end
		GAMEMNG.PSTATE[2].power = "";
	end
end

function GAMEMNG.drawState(id,x,y)
	if(id==1 or id==2) then
		for i = 1, GAMEMNG.PSTATE[id].gun do
			local dir
			if i == 1 then
				dir = (math.pi/2)
			elseif i == 2 then
				dir = -(math.pi/2)
			end
			local x = BALL.list[id].pos[1] + (math.cos(BALL.list[id].dir + dir)*(BALL.list[id].rad)*BALL.ballScale) + BALL.ballCenter[1];
			local y = BALL.list[id].pos[2] + (math.sin(BALL.list[id].dir + dir)*(BALL.list[id].rad)*BALL.ballScale) + BALL.ballCenter[2];
			love.graphics.draw(ASSET.sprites.gun,x,y,BALL.list[id].dir + dir + (math.pi/2),1.5,1.5,ASSET.sprites.gun:getWidth()/2, ASSET.sprites.gun:getHeight());
		end

		if(GAMEMNG.PSTATE[id].power == "drill") or GAMEMNG.PSTATE[id].drtime>0 then
			local x = BALL.list[id].pos[1] + (math.cos(BALL.list[id].dir)*(BALL.list[id].rad)*BALL.ballScale) + BALL.ballCenter[1];
			local y = BALL.list[id].pos[2] + (math.sin(BALL.list[id].dir)*(BALL.list[id].rad)*BALL.ballScale) + BALL.ballCenter[2];
			rand = math.abs(math.ceil(2*math.sin(30*GAMEMNG.PSTATE[id].drtime)+1));
			love.graphics.draw(ASSET.sprites["drill"..(rand)],x,y,BALL.list[id].dir+(math.pi/2),1.5,1.5,ASSET.sprites["drill"..(rand)]:getWidth()/2, ASSET.sprites["drill"..(rand)]:getHeight());
		elseif(GAMEMNG.PSTATE[id].power == "boom") then
			love.graphics.draw(ASSET.sprites.bigthrust,x - (math.cos(BALL.list[id].dir)*BALL.list[id].rad*BALL.ballScale),y - (math.sin(BALL.list[id].dir)*BALL.list[id].rad*BALL.ballScale),BALL.list[id].dir+(-math.pi/2),1,-1,ASSET.sprites.thruster:getWidth()/2,0);
		elseif(GAMEMNG.PSTATE[id].power == "gshot") then
			local x = BALL.list[id].pos[1] + (math.cos(BALL.list[id].dir)*(BALL.list[id].rad)*BALL.ballScale) + BALL.ballCenter[1];
			local y = BALL.list[id].pos[2] + (math.sin(BALL.list[id].dir)*(BALL.list[id].rad)*BALL.ballScale) + BALL.ballCenter[2];
			love.graphics.draw(ASSET.sprites.gshot,x,y,BALL.list[id].dir + (math.pi/2),1.5,1.5,ASSET.sprites.gshot:getWidth()/2, ASSET.sprites.gshot:getHeight()); 
		elseif(GAMEMNG.PSTATE[id].power == "flag") then
			local x = BALL.list[id].pos[1] + (math.cos(BALL.list[id].dir)*(BALL.list[id].rad)*BALL.ballScale) + BALL.ballCenter[1];
			local y = BALL.list[id].pos[2] + (math.sin(BALL.list[id].dir)*(BALL.list[id].rad)*BALL.ballScale) + BALL.ballCenter[2];
			love.graphics.draw(ASSET.sprites.flag,x,y,BALL.list[id].dir+ (math.pi/2),1.5,1.5,0, ASSET.sprites.flag:getHeight());
			love.graphics.setCanvas(canvas);
			local mR,mG,mB,mA = love.graphics.getColor();
			love.graphics.setColor(255-(math.random()*32),255-(math.random()*64),(math.random()*255));
			love.graphics.points({{x + (math.cos(math.random()*2*math.pi)*math.random()*2*BALL.list[id].rad*BALL.ballScale),y+ (math.sin(math.random()*2*math.pi)*math.random()*2*BALL.list[id].rad*BALL.ballScale)}});
			love.graphics.setCanvas();
			love.graphics.setColor(mR,mG,mB,mA);--reapply old colors
		end
	end
end

function GAMEMNG.randomPowerSpawn()
	if GAMEMNG.POWCOUNT > 4 then return end 
	if GAMEMNG.NEXTPOW > #GAMEMNG.POWLIST then
		GAMEMNG.NEXTPOW = 1;
	end
	local type = GAMEMNG.POWLIST[GAMEMNG.NEXTPOW];
	GAMEMNG.NEXTPOW = GAMEMNG.NEXTPOW + 1;
	if (type == "flag" and GAMEMNG.FLAG) then
		type = "gun"
	end	
	GAMEMNG.POWCOUNT = GAMEMNG.POWCOUNT + 1;
	local x = ((winW)*math.random()*BALL.ballScale)-BALL.ballCenter[1];
	local y = ((winH)*math.random()*BALL.ballScale)-BALL.ballCenter[2];
	local id = BALL.new(x,y,15,1,{255,255,255,255},nil,ASSET.sprites[GAMEMNG.SPRITELIST[type]]);
	BALL.list[id].dir = math.random()*math.pi*2;
	BALL.list[id].vel = V.vectorize({(math.random()*2)-1,(math.random()*2)-1}) * 100;
	BALL.list[id].power = type;
	BALL.list[id].frag = 1;
	if type =="flag" then
		GAMEMNG.FLAG = true;
	end
	BALL.list[id].quad = love.graphics.newQuad( 0, 0, ASSET.sprites[GAMEMNG.SPRITELIST[type]]:getWidth(), ASSET.sprites[GAMEMNG.SPRITELIST[type]]:getHeight(), ASSET.sprites[GAMEMNG.SPRITELIST[type]]:getWidth(), ASSET.sprites[GAMEMNG.SPRITELIST[type]]:getHeight());
	BALL.list[id].shadquad = BALL.list[id].quad;
end

function GAMEMNG.spawnFlag(x,y,vel)
	local type = "flag";
	local id = BALL.new(x,y,20,1,{255,255,255,255},nil,ASSET.sprites[GAMEMNG.SPRITELIST[type]]);
	BALL.list[id].dir = math.random()*math.pi*2;
	BALL.list[id].power = type;
	BALL.list[id].quad = love.graphics.newQuad( 0, 0, ASSET.sprites[GAMEMNG.SPRITELIST[type]]:getWidth(), ASSET.sprites[GAMEMNG.SPRITELIST[type]]:getHeight(), ASSET.sprites[GAMEMNG.SPRITELIST[type]]:getWidth(), ASSET.sprites[GAMEMNG.SPRITELIST[type]]:getHeight());
	BALL.list[id].shadquad = BALL.list[id].quad;
	BALL.list[id].vel = vel;
end
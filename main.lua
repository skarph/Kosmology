--[[
Welcome to my personal hell.

~Max
]]
GTIME = 0; --global timer
GFRAME = 0; --global frame count
function love.load()
	love.window.setMode(1920,1080,{borderless = true});
	winW , winH = love.graphics.getDimensions();
	canvas = love.graphics.newCanvas(winW,winH);
	overlay = love.graphics.newCanvas(winW,winH);
	love.window.setTitle("Cologne or Bust");
	require("vectorConstruct");
	JSON = require("json");
	require("ball");
  	require("playerInterface");
	require("gui");
	require("assetHandler");
	require("levelLoader");
	require("menuLoader");
	require("console");
	require("game");
	love.graphics.setDefaultFilter( "nearest","nearest");
	ASSET.load();--loads all assets
	math.randomseed(os.time());
	LEVEL.load(ASSET.levels.example);
	--MENU.load(ASSET.menus.alphaMenu);
	love.graphics.setFont(ASSET.fonts.PressStart2P);
	Joysticks = love.joystick.getJoysticks();

end

function love.quit()
	return false;
end

function love.update(dt)
	GTIME = GTIME + dt;
	if GTIME<10 then return; end
	GAMEMNG.updateStat(dt);
	GAMEMNG.randomPowerSpawn();
	for k, v in ipairs(Joysticks) do
		PINTER.doKeysIfDown(Joysticks[k]);
		PINTER.doSticks(Joysticks[k]);
	end
	BALL.approachBallCenter(dt)
	dtime = dt * BALL.pTimeMult --time delta used for updating balls
	if BALL.doPhysUp then --update global timer
		GFRAME = GFRAME + 1;
    	physUpdate(dt*BALL.pTimeMult,TOUCHES);
	end
	BALL.cleanup();
end

function love.draw()
	if GTIME < 10 then
		love.graphics.setColor({255,255,0,255});
		love.graphics.print("KOSMOLOGY",0,200,0,10);
		love.graphics.print("[Max N; 2018]",0,winH-200,0)
		return;
	end
	BALL.tailLen =  BALL.tailLen % 256;
	love.graphics.setCanvas(canvas);
	love.graphics.setBlendMode("subtract", "alphamultiply");
	love.graphics.setColor(0xFF,0xFF,0xFF,BALL.tailLen);
	love.graphics.rectangle('fill',0,0,winW,winH);
	if BALL.doPhysUp then
		BALL.tailLen = 0x01;
	else
		if BALL.tailLen < 0xFF then
			BALL.tailLen = BALL.tailLen + 0.1;
		end
	end
	love.graphics.setBlendMode("alpha", "alphamultiply");
	if BALL.doPhysUp then
		for i, v in pairs(BALL.list) do
			if BALL.list[i] then
				BALL.list[i]:drawTrail();--incase BALL[i]==nil
			end
		end
	end
	love.graphics.setCanvas();
	love.graphics.setBlendMode("alpha", "premultiplied");
	love.graphics.setColor(0xFF,0xFF,0xFF,0xFF);
	love.graphics.draw(canvas);

	love.graphics.setColor(0xFF,0xFF,0xFF,0xFF);
	love.graphics.setBlendMode("alpha", "alphamultiply");
	for i, v in pairs(BALL.list) do
		if BALL.list[i] then
			BALL.list[i]:draw();--incase BALL[i]==nil
		end
	end

	if GAMEMNG.RESET then
		GAMEMNG.OVERFADE = 255;
	end

	if GAMEMNG.OVERFADE > 0 then
		GAMEMNG.OVERFADE = GAMEMNG.OVERFADE - 1;
		love.graphics.setBlendMode("alpha", "alphamultiply");
		love.graphics.setColor(BALL.list[1].color[1],BALL.list[1].color[2],BALL.list[1].color[3],GAMEMNG.OVERFADE);
		love.graphics.print(string.format("%02d",GAMEMNG.PSTATE[1].score),0,(winH/2)-140,0,20);
		love.graphics.setColor(255,255,255,GAMEMNG.OVERFADE);
		love.graphics.print("-",(winW/2)-160,(winH/2)-125,0,20);
		love.graphics.setColor(BALL.list[2].color[1],BALL.list[2].color[2],BALL.list[2].color[3],GAMEMNG.OVERFADE);
		love.graphics.print(string.format("%02d",GAMEMNG.PSTATE[2].score),winW-700,(winH/2)-140,0,20);
	end
	--DEBUG AHEAD
	love.graphics.setColor(64,255,64,255);
	CONSOLE.VALS.FPS = string.format("%.2f",love.timer.getFPS( ));
	CONSOLE.VALS.Time = string.format("%0.1f",GTIME);
	CONSOLE.VALS.MemUse = string.format("%0.1f",collectgarbage('count')).."kB";
	--love.graphics.print(CONSOLE.getString());
	--[[local vec = ((BALL.ballCenter-V.vectorize({winW/2,winH/2})))+V.vectorize({winW/2,winH/2});
	love.graphics.setColor(0xFF,0xFF,0x00,0x7F);
	love.graphics.circle("fill",BALL.ballCenter[1],BALL.ballCenter[2],5);
	love.graphics.line(winW/2,winH/2,vec[1],vec[2]);
	love.graphics.setColor(0x00,0xFF,0xFF,0x7F);
	local vec2 = 
	(((BALL.cenTar-V.vectorize({winW/2,winH/2}))))+V.vectorize({winW/2,winH/2});
	love.graphics.circle("fill",BALL.cenTar[1],BALL.cenTar[2],7);
	love.graphics.line(winW/2,winH/2,vec2[1],vec2[2]);
	love.graphics.setColor(0xFF,0x00,0xFF,0x7F);
	--love.graphics.print("\n\n"..vec[1].."\t"..vec[2]);
	love.graphics.setColor(0xFF,0xFF,0xFF,0xFF);
	--Debug End]]
end

function love.gamepadreleased( joystick, button )
end

function love.gamepadpressed( joystick, button )
	PINTER.doKey(button,{player = joystick:getID(),isheld = false});
end

function physUpdate(dtime,touches)
	BALL.grav(); --solve gravity	
	BALL.doCollisions(); --solve any collisions
	--CONSOLE.VALS.SamBa = BALL.list[2].pos[1].." , "..BALL.list[2].pos[2];
	local iter = 0;
	for i, v in pairs(BALL.list) do --updating solved per ball. May be useful when deciding to 'speed up' some balls.
		if BALL.list[i] then
			iter = iter + 1;
			BALL.list[i]:update(dtime);
		end
	end
end
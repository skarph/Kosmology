--[[
Welcome to my personal hell.

~Max
]]
GTIME = 0; --global timer
GFRAME = 0; --global frame count
INTROFADE = 1/math.pow(GTIME,3);
FLASH = 0
local vercon = {love.getVersion()};
VER = vercon[1].."."..vercon[2].."."..vercon[3];
function love.load()
	love.window.setMode(1920,1080,{borderless = true});
	winW , winH = love.graphics.getDimensions();
	canvas = love.graphics.newCanvas(winW,winH);
	overlay = love.graphics.newCanvas(winW,winH);
	love.window.setTitle("KOSMOLOGY");
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
	--MENU.load(ASSET.menus.alphaMenu);
	love.graphics.setFont(ASSET.fonts.PressStart2P);
	Joysticks = love.joystick.getJoysticks();
	love.setDeprecationOutput( false );
end

function love.quit()
	return false;
end

function love.update(dt)
	GTIME = GTIME + dt;
	GFRAME = GFRAME + 1;
	CONSOLE.VALS.timeout = PINTER.INACTIVETIME;
	local didSomething = false;
	for k, v in ipairs(Joysticks) do
		didSomething = PINTER.doSticks(Joysticks[k]) or didSomething;
		didSomething = PINTER.doKeysIfDown(Joysticks[k]) or didSomething;
	end
	CONSOLE.VALS.activity = tostring(didSomething);
	if PINTER.INACTIVETIME >= 0 then
		PINTER.INACTIVETIME = PINTER.INACTIVETIME - dt;
		if PINTER.INACTIVETIME <= 5 then
			if PINTER.INACTIVETIME >= 4.75 then
			GTIME = 5.25;
			end
			GTIME = GTIME - (2 * dt);
		end
	else
		PINTER.INACTIVETIME = 0;
		LEVEL.unload();
		if didSomething then
			LEVEL.load(ASSET.levels.example);
			PINTER.INACTIVETIME = PINTER.TIMEOUT;
		end
		GTIME = 0.01;
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
		GAMEMNG.RESET = true;
		GAMEMNG.FLAG = false;
		GAMEMNG.POWCOUNT = 0;
	end

	if (GTIME < 0.1) then return; end
	
	if didSomething then
		PINTER.INACTIVETIME = PINTER.TIMEOUT;
	end

	GAMEMNG.updateStat(dt);
	GAMEMNG.randomPowerSpawn();
	GAMEMNG.spawnFlag((winW*BALL.ballScale*math.random())-BALL.ballCenter[1],(winH*BALL.ballScale*math.random())-BALL.ballCenter[2],V.vectorize({math.random(),math.random()}):norm()*25);
	BALL.approachBallCenter(dt)
	dtime = dt * BALL.pTimeMult --time delta used for updating balls
	if BALL.doPhysUp then --update global timer
    	physUpdate(dt*BALL.pTimeMult,TOUCHES);
	end
end

function love.draw()
	love.graphics.setBlendMode("alpha", "alphamultiply");
	INTROFADE = (0.1/(0.1+GTIME));
	if GTIME < 5 then
		love.graphics.setColor({1,1,1,1*INTROFADE});
		love.graphics.draw(ASSET.sprites.logo,(winW/2)-(ASSET.sprites.logo:getWidth()*6.5),(winH/2)-(ASSET.sprites.logo:getHeight()*10),0,13,20);
		if GFRAME % 144 == 0 then
			FLASH = (FLASH + 1) % 2
		end
		if FLASH == 1 then
			love.graphics.print("PRESS A",(winW/2)-350,25,0,5,5);
		end
		love.graphics.print("A/B . . . . . BOOST\nX/Y . . . . . SHOOT\nL/R . . . . . SPECIAL\n\n\t  CAPTURE THE FLAG",(winW/2)-420,890,0,1.5,1.5);
		love.graphics.print("[Max N; 2018]",0,winH-100,0,0.5,0.5);
	else
		INTROFAD = 0;
	end

	love.graphics.setCanvas(canvas);
	love.graphics.setBlendMode("subtract", "alphamultiply");
	love.graphics.setColor(1,1,1,0.01);
	love.graphics.rectangle('fill',0,0,winW,winH);
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
	love.graphics.draw(canvas);

	love.graphics.setColor(1,1,1,1-(INTROFADE));
	love.graphics.setBlendMode("alpha", "alphamultiply");
	for i, v in pairs(BALL.list) do
		if BALL.list[i] then
			BALL.list[i]:draw();--incase BALL[i]==nil
			BALL.list[i].colCheck = {};
		end
	end

	if GAMEMNG.OVERFADE > 0 then
		GAMEMNG.OVERFADE = GAMEMNG.OVERFADE - 1;
		love.graphics.setBlendMode("alpha", "alphamultiply");
		love.graphics.setColor(BALL.list[1].color[1],BALL.list[1].color[2],BALL.list[1].color[3],GAMEMNG.OVERFADE);
		love.graphics.print(string.format("%02d",GAMEMNG.PSTATE[1].score),0,(winH/2)-140,0,20);
		love.graphics.setColor(1,1,1,GAMEMNG.OVERFADE);
		love.graphics.print("-",(winW/2)-160,(winH/2)-125,0,20);
		love.graphics.setColor(BALL.list[2].color[1],BALL.list[2].color[2],BALL.list[2].color[3],GAMEMNG.OVERFADE);
		love.graphics.print(string.format("%02d",GAMEMNG.PSTATE[2].score),winW-700,(winH/2)-140,0,20);
	end
	--DEBUG AHEAD
	love.graphics.setColor(64/0xFF,1,64/0xFF,P1);
	CONSOLE.VALS.FPS = string.format("%.2f",love.timer.getFPS( ));
	CONSOLE.VALS.Time = string.format("%0.1f",GTIME);
	CONSOLE.VALS.MemUse = string.format("%0.1f",collectgarbage('count')).."kB";
	CONSOLE.VALS.ver = VER;
	CONSOLE.VALS.fade = 1-(INTROFADE);
	love.graphics.print(CONSOLE.getString());
	
	--[[local vec = ((BALL.ballCenter-V.vectorize({winW/2,winH/2})))+V.vectorize({winW/2,winH/2});
	love.graphics.setColor(1,1,0x00,0x7F);
	love.graphics.circle("fill",BALL.ballCenter[1],BALL.ballCenter[2],5);
	love.graphics.line(winW/2,winH/2,vec[1],vec[2]);
	love.graphics.setColor(0x00,1,1,0x7F);
	local vec2 = 
	(((BALL.cenTar-V.vectorize({winW/2,winH/2}))))+V.vectorize({winW/2,winH/2});
	love.graphics.circle("fill",BALL.cenTar[1],BALL.cenTar[2],7);
	love.graphics.line(winW/2,winH/2,vec2[1],vec2[2]);
	love.graphics.setColor(1,0x00,1,0x7F);
	--love.graphics.print("\n\n"..vec[1].."\t"..vec[2]);
	love.graphics.setColor(1,1,1,1);
	--Debug End]]
end

function love.gamepadreleased( joystick, button )
end

function love.gamepadpressed( joystick, button )
	PINTER.doKey(button,{player = joystick:getID(),isheld = false});
end

function physUpdate(dtime,touches)
	local iter = 0;
	BALL.grav(); --solve gravity	
	BALL.doCollisions(); --solve any collisions
	for i, v in pairs(BALL.list) do --updating solved per ball. May be useful when deciding to 'speed up' some balls.
		if BALL.list[i] then
			iter = iter + 1;
			BALL.list[i]:update(dtime);
		end
	end
	BALL.cleanup();
	CONSOLE.VALS.index = BALL.lastIndex
	CONSOLE.VALS.track = BALL.count;
	--CONSOLE.VALS.SamBa = BALL.list[2].pos[1].." , "..BALL.list[2].pos[2];
	CONSOLE.VALS.iter = iter;
end
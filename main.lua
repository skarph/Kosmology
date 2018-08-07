GTIME = 0; --global timer

function love.load()

	love.window.setMode(1920,1080);
	winW , winH = love.graphics.getDimensions();
	canvas = love.graphics.newCanvas(winW,winH);
	love.window.setTitle("Cologne or Bust");
	require("vectorConstruct");
	JSON = require("json");
	require("ball");
  	require("playerInterface");
	require("gui");
	require("assetHandler");
	require("levelLoader");
	require("menuLoader");
	ASSET.load();--loads all assets
	
	math.randomseed(os.time());
	LEVEL.load(ASSET.levels.example);
	--MENU.load(ASSET.menus.alphaMenu);
	Joysticks = love.joystick.getJoysticks();

end

function love.quit()
	return false;
end

function love.update(dt)
	for k, v in ipairs(Joysticks) do
		PINTER.doKeysIfDown(Joysticks[k]);
	end
	BALL.approachBallCenter(dt)
	dtime = dt * BALL.pTimeMult --time delta used for updating balls
	if BALL.doPhysUp then
		GTIME = GTIME + dtime; --update global timer
    	physUpdate(dt*BALL.pTimeMult,TOUCHES);
	end
end

function love.draw()
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
		for i=1, BALL.lastIndex do
			if BALL.list[i] then
				BALL.list[i]:drawTrail();--incase BALL[i]==nil
			end
		end
	end
	
	love.graphics.setColor(255,255,255,255);
	love.graphics.setCanvas();

	love.graphics.setBlendMode("alpha", "premultiplied");
	love.graphics.setColor(0xFF,0xFF,0xFF,0xFF);
	love.graphics.draw(canvas);

	love.graphics.setColor(0xFF,0xFF,0xFF,0xFF);
	love.graphics.setBlendMode("alpha", "alphamultiply");
	for i=1, BALL.lastIndex do
		if BALL.list[i] then
			BALL.list[i]:draw();--incase BALL[i]==nil
		end
	end
	
	--MENU.render();
	
	--DEBUG AHEAD
	
	--love.graphics.print("FPS:\t"..string.format("%.2f",love.timer.getFPS( )).."\nTime:\t"..string.format("%0.1f",GTIME).."\n MemUsage:\t"..string.format("%0.1f",collectgarbage('count')).."kB");
	local vec = ((BALL.ballCenter-V.vectorize({winW/2,winH/2})))+V.vectorize({winW/2,winH/2});
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
	--Debug End
end

function love.gamepadreleased( joystick, button )
end

function love.gamepadpressed( joystick, button )
	PINTER.doKey(button,{player = joystick:getID(),isheld = false});
end

function physUpdate(dtime,touches)
	BALL.grav(); --solve gravity	
	
	BALL.doCollisions(); --solve any collisions
	
	for i=1, BALL.lastIndex do --updating solved per ball. May be useful when deciding to 'speed up' some balls.
		if BALL.list[i] then
			BALL.list[i]:update(dtime);
		end
	end

end
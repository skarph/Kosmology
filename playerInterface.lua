PINTER = {};
PINTER.INACTIVETIME = 0;
PINTER.TIMEOUT = 20;
COMMAND = {};
COMMAND.BOOST = {"b","a"};
COMMAND.SHOOT = {"x","y"};
COMMAND.SPECIAL = {"rightshoulder","leftshoulder"}
COMMAND.TURN = {"stick"};

function PINTER.getKeyAssignments(key)
	local list = {}
	local i = 1
	for k,v in pairs(COMMAND) do
		for m,j in ipairs(COMMAND[k]) do
			if COMMAND[k][m] == key then
				list[i] = k;
				break;
			end
		end
	end
	return list;
end

function PINTER.doKey(key,arg,keyassignment)
	keycom = keyassignment or PINTER.getKeyAssignments(key);
	if keycom[1] then
		for k,v in ipairs(keycom) do
			PINTER[keycom[k]](key,arg);
			return true;
		end
	end
end

function PINTER.doKeysIfDown(joystick)
	for k,v in pairs(COMMAND) do
		for m,j in ipairs(COMMAND[k]) do
			if not(COMMAND[k][m]=="stick") then --screw it 
				if joystick:isGamepadDown(COMMAND[k][m]) then
					return PINTER.doKey(nil,{player = joystick:getID(),isheld = true},{k});
				end
			end
		end
	end		
end

function PINTER.doSticks(joystick)
	local axes = {joystick:getAxes( )}
	local bigdir = {}
	if (math.abs(math.floor(axes[1]*10))-1>0) or (math.abs(math.floor(axes[2]*10))-1>0) or (math.abs(math.floor(axes[4]*10))-1>0) or (math.abs(math.floor(axes[5]*10))-1>0) then
		if(math.abs(axes[1])>math.abs(axes[4])) then
			bigdir[1] = axes[1];
		else
			bigdir[1] = axes[4];
		end
		if(math.abs(axes[2])>math.abs(axes[5]))then
			bigdir[2] = axes[2];
		else
			bigdir[2] = axes[5];
		end
		return PINTER.doKey("stick",{player = joystick:getID(),x = bigdir[1],y = bigdir[2]});
	end
end
------------------------------------------------------------------------------
---------------------------BUTTON CALLBACKS START!----------------------------
------------------------------------------------------------------------------

function PINTER.BOOST(key, arg)
	if(BALL.list[arg.player]) then
		BALL.list[arg.player].acc = BALL.list[arg.player].acc + (V.vectorize({math.cos(BALL.list[arg.player].dir),math.sin(BALL.list[arg.player].dir)})*50);
		BALL.list[arg.player].spin = BALL.list[arg.player].spin*0.99;
		GAMEMNG.PSTATE[arg.player].boost = true;
	end
end

function PINTER.SHOOT(key, arg)
	if BALL.list[arg.player] and not arg.isheld and GAMEMNG.PSTATE[arg.player].bullets < GAMEMNG.PSTATE[arg.player].gun * 5 then
		local x1 = BALL.list[arg.player].pos[1] + (math.cos(BALL.list[arg.player].dir + math.pi/2)*(BALL.list[arg.player].rad + 16)*BALL.ballScale);
		local y1 = BALL.list[arg.player].pos[2] + (math.sin(BALL.list[arg.player].dir + math.pi/2)*(BALL.list[arg.player].rad+ 16)*BALL.ballScale);
		if GAMEMNG.PSTATE[arg.player].gun == 1 then
			local id1 = BALL.new(x1,y1,5,5,BALL.list[arg.player].color,nil,BALL.list[arg.player].img,nil,1,-arg.player);
			BALL.list[id1].vel = (V.vectorize({math.cos(BALL.list[arg.player].dir),math.sin(BALL.list[arg.player].dir)})*500);
			BALL.list[id1].isBullet = true;
			GAMEMNG.PSTATE[arg.player].bullets = GAMEMNG.PSTATE[arg.player].bullets + 1;
			--BALL.list[id1].iFrame = 20;
		end

		if GAMEMNG.PSTATE[arg.player].gun == 2 then
			if key == "x" then
				local x2 = BALL.list[arg.player].pos[1] + (math.cos(BALL.list[arg.player].dir - math.pi/2)*(BALL.list[arg.player].rad + 16)*BALL.ballScale);
				local y2 = BALL.list[arg.player].pos[2] + (math.sin(BALL.list[arg.player].dir - math.pi/2)*(BALL.list[arg.player].rad + 16)*BALL.ballScale);

				local id2 = BALL.new(x2,y2,5,5,BALL.list[arg.player].color,nil,BALL.list[arg.player].img,nil,1,-arg.player);
				BALL.list[id2].vel = (V.vectorize({math.cos(BALL.list[arg.player].dir),math.sin(BALL.list[arg.player].dir)})*500);
				GAMEMNG.PSTATE[arg.player].bullets = GAMEMNG.PSTATE[arg.player].bullets + 1;
				--BALL.list[id2].iFrame = 20;
			end

			if key == "y"then
				local x1 = BALL.list[arg.player].pos[1] + (math.cos(BALL.list[arg.player].dir + math.pi/2)*(BALL.list[arg.player].rad + 16)*BALL.ballScale);
				local y1 = BALL.list[arg.player].pos[2] + (math.sin(BALL.list[arg.player].dir + math.pi/2)*(BALL.list[arg.player].rad+ 16)*BALL.ballScale);
				local id1 = BALL.new(x1,y1,5,5,BALL.list[arg.player].color,nil,BALL.list[arg.player].img,nil,1,-arg.player);
				BALL.list[id1].vel = (V.vectorize({math.cos(BALL.list[arg.player].dir),math.sin(BALL.list[arg.player].dir)})*500);
				GAMEMNG.PSTATE[arg.player].bullets = GAMEMNG.PSTATE[arg.player].bullets + 1;
				--BALL.list[id1].iFrame = 20;
			end
		end
	end
end

function PINTER.TURN(key, arg)
	if(BALL.list[arg.player]) then
		BALL.list[arg.player].vel = BALL.list[arg.player].vel*(1-(math.abs(arg.x)*0.005));
		if GAMEMNG.PSTATE[arg.player].drtime > 0 then
			BALL.list[arg.player].spin = arg.x * (2 * math.pi);
		else
			BALL.list[arg.player].spin = BALL.list[arg.player].spin + arg.x*0.1;
		end
	end
end

function PINTER.SPECIAL(key, arg)
	if  BALL.list[arg.player] and (not arg.isheld) then
		if(GAMEMNG.PSTATE[arg.player].power == "gshot") then
			local x1 = BALL.list[arg.player].pos[1] + (math.cos(BALL.list[arg.player].dir )*(BALL.list[arg.player].rad + 7)*BALL.ballScale);
			local y1 = BALL.list[arg.player].pos[2] + (math.sin(BALL.list[arg.player].dir )*(BALL.list[arg.player].rad + 7)*BALL.ballScale);
			local id1 = BALL.new(x1,y1,5,1,BALL.list[arg.player].color,nil,ASSET.sprites.magnet,nil,1,arg.player+2);
			BALL.list[id1].vel = BALL.list[arg.player].vel + (V.vectorize({math.cos(BALL.list[arg.player].dir),math.sin(BALL.list[arg.player].dir)})*250);
			BALL.list[id1].speed = 250;
			BALL.list[id1].spin = 0;
			BALL.list[id1].quad = love.graphics.newQuad( 0, 0, ASSET.sprites.magnet:getWidth(), ASSET.sprites.magnet:getHeight(), ASSET.sprites.magnet:getWidth(), ASSET.sprites.magnet:getHeight());
			BALL.list[id1].shadquad = BALL.list[id1].quad;
			if(arg.player == 1) then
				BALL.list[id1].seek = 2;
			else
				BALL.list[id1].seek = 1;
			end
		elseif(GAMEMNG.PSTATE[arg.player].power == "boom") then
			--rocket BOOST
			BALL.list[arg.player].vel = BALL.list[arg.player].vel + V.vectorize({math.cos(BALL.list[arg.player].dir),math.sin(BALL.list[arg.player].dir)})*500;
			for k, v in pairs(BALL.list) do
				if (BALL.list[i]~=0) then
					if k == arg.player then
					else
					BALL.list[k].vel = BALL.list[k].vel + ((BALL.list[arg.player].pos-BALL.list[k].pos):norm()*-2500/(BALL.list[arg.player].pos-BALL.list[k].pos):getMagnitude());
					end
				end
			end
		elseif(GAMEMNG.PSTATE[arg.player].power == "drill") then
			--invicibility?
			BALL.list[arg.player].vel = V.vectorize({0,0});
			BALL.list[arg.player].spin = 0;
			GAMEMNG.PSTATE[arg.player].drtime = 3.0;
		elseif(GAMEMNG.PSTATE[arg.player].power == "flag") then
			local x = (math.cos(BALL.list[arg.player].dir )*(BALL.list[arg.player].rad + 16)*BALL.ballScale) + BALL.list[arg.player].pos[1];
			local y = (math.sin(BALL.list[arg.player].dir )*(BALL.list[arg.player].rad + 16)*BALL.ballScale) + BALL.list[arg.player].pos[2];
			local vel  = V.vectorize({math.cos(BALL.list[arg.player].dir),math.sin(BALL.list[arg.player].dir)})*150;
			GAMEMNG.FLAG = false;
			GAMEMNG.spawnFlag(x,y,vel)
		end
		GAMEMNG.PSTATE[arg.player].power = "";
	end	
end
PINTER = {};
COMMAND = {};
COMMAND.BOOST = "a";
COMMAND.SHOOT = "b"
COMMAND.TURN = "stick";
function PINTER.getKeyAssignment(key)
	for k,v in pairs(COMMAND) do
		if COMMAND[k] == key then
			return k;
		end
	end
	return nil;
end

function PINTER.doKey(key,arg,keyassignment)
	keycom = keyassignment or PINTER.getKeyAssignment(key);
	if keycom then
		PINTER[keycom](arg);
	end
end

function PINTER.doKeysIfDown(joystick)
	for k,v in pairs(COMMAND) do
		if (COMMAND[k]=="a") or (COMMAND[k]=="b") or (COMMAND[k]=="x") or (COMMAND[k]=="y") or (COMMAND[k]=="start") then --screw it 
			if joystick:isGamepadDown(COMMAND[k]) then
				PINTER.doKey(nil,{player = joystick:getID(),isheld = true}, k);
			end
		end
	end		
end

function PINTER.doSticks(joystick)
	local axes = joystick:getAxes( )
	axes = {{axes[1],axes[2]},{axes[4],axes[5]}};
	axes[3] = {0,0}
	if Joystick:isGamepadDown("dpright")
		axes[3][1] = axes[3][1] + 1
	end
	if Joystick:isGamepadDown("dpleft")
		axes[3][1] = axes[3][1] - 1
	end
	if Joystick:isGamepadDown("dpup")
		axes[3][2] = axes[3][2] + 1
	end
	if Joystick:isGamepadDown("dpdown")
		axes[3][2] = axes[3][2] - 1
	end
end
------------------------------------------------------------------------------
---------------------------BUTTON CALLBACKS START!----------------------------
------------------------------------------------------------------------------

function PINTER.BOOST(arg)
	if not arg.isheld then
		print(arg.player.." boost")
	end
end

function PINTER.SHOOT(arg)
	if not arg.isheld then
		print(arg.player.." pew")
	end
end

function PINTER.TURN(arg)
	print(arg.player.." vrooms "..arg.dX)
end
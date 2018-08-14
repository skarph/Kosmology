BALL = {}
BALL.__index = BALL;
BALL.list={}-->>table that contains all balls

BALL.lastIndex=0;--Last index of BALL.list

BALL.G = 5 -->>Gravititational constant

BALL.ballScale = 1; --multiplyer for radius when drawing

BALL.ballCenter = V.vectorize{winW/2,winH/2}; --onscreen coords corresponding to 0,0 in game
BALL.cenTar = BALL.ballCenter; --centaurs (center target)
BALL.cenSpe = 500;
BALL.superJumpDist = 0.5;
BALL.pTimeMult = 1;
BALL.touchMass = 500; --mass of invisible ball spawned upon click
BALL.doPhysUp = true; --do updates for balls
BALL.tailLen = 0x01;

BALL.delQueue = {};
function BALL.approachBallCenter(tick)
	local jumpDist = tick*BALL.cenSpe;
	if BALL.ballCenter:distTo(BALL.cenTar) < BALL.cenSpe then
		jumpDist = BALL.cenSpe*tick*(BALL.ballCenter:distTo(BALL.cenTar)/BALL.cenSpe);
	end
	if BALL.ballCenter:distTo(BALL.cenTar) < BALL.superJumpDist then
		BALL.ballCenter = BALL.cenTar;	
	end
	BALL.ballCenter = BALL.ballCenter + (jumpDist * (BALL.cenTar - BALL.ballCenter):norm());
end

function BALL.new(x,y,rad,mass,color,lock,img,quad,frag,player,speed) -->> creates a new ball object, stores object in BALL.list, returns id of ball
	local self = {};
	if color then
		if not color[1] then
			color = nil;
		end
	end
	setmetatable(self,{__index=BALL});
	self.id = BALL.getNewID();
	self.pos = V.vectorize({x,y});
	self.rad = rad; --radius
	self.mass = mass; --mass, arb. unit
	self.color = color or {math.ceil(math.random()*0xFF),math.ceil(math.random()*0xFF),math.ceil(math.random()*0xFF),0xFF} --color or random
	self.dir = 0; --radians
	self.vel = V.vectorize({0,0});--units/sec
	self.acc = V.vectorize({0,0}); --units/sec^2
	self.spin = math.pi/5;--quantum unit, jk, not used as of now
	self.colCheck = {}--collision check littwhat was actually said. Strawman. Can lead to wrong concwhat was actually said. Strawman. Can lead to wrong conclusionslusions
	self.hasCol = {};--post-solve list
	self.iFrames = 0;--time where colls don't count
	self.lock = lock; --whether or not ball is static
	self.frag = frag;--Number of collisions before destroying
	self.player = player;
	self.speed = speed or 500;
	if self.id == 1 or self.id ==2 then
		self.player = self.id
	end
	if not(rad==0) then
		self.img = img; --image the ball draws from
		quadNum = quadNum or (math.floor(math.random()*10)); --random 0 to 3. temporary randomizer
		self.quad = qaud or love.graphics.newQuad(0,self.img:getHeight()*quadNum*0.1,self.img:getWidth()/2,self.img:getHeight()*0.1,self.img:getDimensions());
		self.shadquad = qaud or love.graphics.newQuad(self.img:getWidth()/2,self.img:getHeight()*quadNum*0.1,self.img:getWidth()/2,self.img:getHeight()*0.1,self.img:getDimensions());
	end
	BALL.list[self.id] = self;
	return self.id;
end

function BALL.getNewID() -->>gets a new id for a new ball 'obj'
	local returnVal = 1;
	for i=1,#BALL.list+1 do
		if not BALL.list[i] then 
			BALL.lastIndex = i;
			return i;
		end
		BALL.lastIndex = i;
	end
	return returnVal;
end


function BALL.update(self,dt)--UPDATE
	
	if(0>=self.pos[1]+BALL.ballCenter[1]) or (winW<=self.pos[1]+BALL.ballCenter[1]) then
		--X
		self.vel[1] = self.vel[1] * -1
		if (0>=self.pos[1]+BALL.ballCenter[1]) then
			self.pos[1] = 1 - BALL.ballCenter[1];
		else
			self.pos[1] = winW-1 - BALL.ballCenter[1];
		end		
		self.pos = self.pos + (self.vel * 0.01)
		if self.frag then 
			self.frag = self.frag - 1;
		end
	end

	if(0>=self.pos[2]+BALL.ballCenter[2]) or (winH<=self.pos[2]+BALL.ballCenter[2]) then
		--Y
		self.vel[2] = self.vel[2] * -1
		if (0>=self.pos[2]+BALL.ballCenter[2]) then
			self.pos[2] = 1 - BALL.ballCenter[2];
		else
			self.pos[2] = winH-1 - BALL.ballCenter[2];
		end
		if self.frag then 
			self.frag = self.frag - 1;
		end
	end

	if self.frag then
		--CONSOLE.VALS[self.id.."Fr"] = self.frag;
		if self.frag <= 0 then
			self:del();
			return;
		end
	end
	if self==nil then return; end
	self.colCheck = {};

	self.hasCol = {};
	
	if not self.lock then
		self.pos = self.pos + (self.vel*dt)
		self.vel = self.vel + (self.acc*dt);
	else
		self.vel = V.vectorize({0,0});
	end
	if(self.speed) then
		if(self.vel:getMagnitude()>self.speed) then
			self.vel = self.vel:norm()*self.speed
		end
	end
	self.acc = V.vectorize({0,0}); --reset acceleration
	self.dir = self.dir+(dt*self.spin);
	if not(self.iFrames==0) then --update invincibility
		self.iFrames=self.iFrames-1;
	end
end

function BALL.doCollisions() -->>does collision check for all balls
	local bbi = nil; --big ball i=nilndex
	local lbi = nil; --long beach island
	local mag = V.getMagnitude;
	local eat = BALL.eat;
	for i=1, BALL.lastIndex do
		for j=i+1, BALL.lastIndex do
			if BALL.list[i] and BALL.list[j] then
				if (not(BALL.list[i].colCheck[j] and BALL.list[j].colCheck[i])) then --AAAAAAAAAAAAAAAAAAAAAAAAAAAA
					if mag(BALL.list[i].pos-BALL.list[j].pos)<=(BALL.list[i].rad + BALL.list[j].rad) then --AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
						if BALL.list[i].frag then
							BALL.list[i].frag = BALL.list[i].frag - 1;
						end

						if BALL.list[j].frag then
							BALL.list[j].frag = BALL.list[j].frag - 1;
						end

						BALL.list[i].colCheck[j] = true;
						BALL.list[j].colCheck[i] = true;
						if BALL.list[i].iFrames <= 0 then
							if BALL.list[i].hasCol[j] and (i==1 or i==2) then
								BALL.list[j].iFrames = 1;
								BALL.list[i].pos = BALL.list[j].pos + ((BALL.list[i].pos-BALL.list[j].pos):norm()*(BALL.list[i].rad+BALL.list[j].rad));
								CONSOLE.log(i.."is stuck!")
							else
								BALL.list[i].hasCol[j] = true;
							end
						end
						
						if BALL.list[j].iFrames <= 0 then
							if BALL.list[j].hasCol[i] and (j==1 or j==2) then
								BALL.list[j].iFrames = 1;
								BALL.list[j].pos = BALL.list[i].pos + ((BALL.list[j].pos-BALL.list[i].pos):norm()*(BALL.list[i].rad+BALL.list[j].rad));
								CONSOLE.log(j.."is stuck!")
							else
								BALL.list[j].hasCol[i] = true;
							end
						end
						if BALL.list[i].power then
							if BALL.list[j].id == 1 or BALL.list[j].id == 2 then
								CONSOLE.log(i.."powered"..j)
								GAMEMNG.PSTATE[j].power = BALL.list[i].power
								BALL.list[i]:del();
							end
						elseif BALL.list[j].power then
							if BALL.list[i].id == 1 or BALL.list[i].id == 2 then
								CONSOLE.log(i.."powered"..j)
								GAMEMNG.PSTATE[i].power = BALL.list[j].power
								BALL.list[j]:del();
							end
						end
						local velI = V.vectorize{BALL.list[i].vel[1],BALL.list[i].vel[2]};
						local velJ = V.vectorize{BALL.list[j].vel[1],BALL.list[j].vel[2]};
						if BALL.list[j].iFrames<=0 then
							BALL.list[j].vel = velJ  - ((
								(2*BALL.list[i].mass)
								/ 
								(BALL.list[i].mass + BALL.list[j].mass)
							) * (
								V.dot(
									velJ - velI , 
									BALL.list[j].pos - BALL.list[i].pos
								)
								/
								math.pow(
									V.getMagnitude(
										BALL.list[j].pos-BALL.list[i].pos
									) ,
									2
								) 
							) * (
								BALL.list[j].pos - BALL.list[i].pos
							));
						end
						if BALL.list[i].iFrames<=0 then
							BALL.list[i].vel = velI  - ((
								(2*BALL.list[j].mass)
								/ 
								(BALL.list[i].mass + BALL.list[j].mass)
							) * (
								V.dot(
									velI - velJ , 
									BALL.list[i].pos - BALL.list[j].pos
								)
								/
								math.pow(
									V.getMagnitude(
										BALL.list[i].pos-BALL.list[j].pos
									) ,
									2
								) 
							) * (
								BALL.list[i].pos - BALL.list[j].pos
							));
						end
						---------------------------------------------
						if(BALL.list[i].player == 3 and BALL.list[j].id == 2) or (BALL.list[i].player == 4 and BALL.list[j].id == 1) or (BALL.list[j].player == 3 and BALL.list[i].id == 2) or (BALL.list[j].player == 4 and BALL.list[i].id == 1) then
							GAMEMNG.PSTATE[1].htime = 1.5;
							GAMEMNG.PSTATE[2].htime = 1.5;
						end
					end
				end
				--for each ball
				if BALL.list[i].hasCol[j] or BALL.list[j].hasCol[i] then
					CONSOLE.log(i.." col "..j)
				end

			end
		end
	end
end

function BALL.grav() -->>similar to doCollisions, does not play nice when integrated with doCollisions
	local dir = nil;
	local dist = nil;
	local norm =  V.norm;
	local mag = V.getMagnitude;
	for i=1, BALL.lastIndex do
		for j=i+1, BALL.lastIndex do
			if BALL.list[i] and BALL.list[j] then
				dir = norm(BALL.list[j].pos - BALL.list[i].pos);
				dist = mag(BALL.list[j].pos - BALL.list[i].pos);
				local inside = 1;
				if dist < BALL.list[i].rad or dist < BALL.list[j].rad then
					inside = -1;
				end
				
				local force = (
					(BALL.G*BALL.list[i].mass*BALL.list[j].mass)
					/
					(dist*dist)
				)*inside;

				--calculates force divided by mass (acceleration)
				if BALL.list[i].seek == BALL.list[j].id then
					BALL.list[i].acc = BALL.list[i].acc + (100000*dir*(force/BALL.list[i].mass)) --increase acc. by appropriate vector force
				end
				if BALL.list[j].seek == BALL.list[i].id then
					BALL.list[j].acc = BALL.list[j].acc + (-100000*dir*(force/BALL.list[j].mass)) --increase acc. by opposite vector force
				end
				if BALL.list[j].seek ~= BALL.list[i].id and BALL.list[i].seek ~= BALL.list[j].id then
					BALL.list[i].acc = BALL.list[i].acc + (dir*(force/BALL.list[i].mass)) --increase acc. by appropriate vector force
					BALL.list[j].acc = BALL.list[j].acc + (-1*dir*(force/BALL.list[j].mass)) --increase acc. by opposite vector force
				end
			end
		end
	end
end


function BALL.eat(ball1,ball2)-->>adds all of the properties of the greater radius ball to lesser radius, destroys lesser. TOREDO
	local pM1 = (ball1.mass/(ball1.mass+ball2.mass));--percent mass of ball1
	local pM2 = (ball2.mass/(ball1.mass+ball2.mass));--percent mass of ball2

	ball1.pos = ball1.pos*(ball1.rad/(ball1.rad+ball2.rad)) + ball2.pos*(ball2.rad/(ball1.rad+ball2.rad)); --adds positions based on percent size
	ball1.rad = ball1.rad+ball2.rad; --increases size
	ball1.vel = (ball1.vel * (ball1.mass/(ball1.mass+ball2.mass))) + (ball2.vel * (ball2.mass/(ball1.mass+ball2.mass)));
	ball1.mass = ball1.mass+ball2.mass;
	ball1.color = {(ball1.color[1]*pM1) + (ball2.color[1]*pM2), (ball1.color[2]*pM1) + (ball2.color[2]*pM2), (ball1.color[3]*pM1) + (ball2.color[3]*pM2), (ball1.color[4]*pM1) + (ball2.color[4]*pM2)} --color change based on percent mass
	ball2:del(); --destroy the second body
end

function BALL.draw(self,disp,scale)-->>call for painting ball
	if self.nodraw then return; end
	local mR,mG,mB,mA = love.graphics.getColor();--remember old colors
	local disp = disp or {BALL.ballCenter[1] , BALL.ballCenter[2]};
	local scale = scale or BALL.ballScale;
	local x = (self.pos[1]*scale) +  disp[1];
	local y = (self.pos[2]*scale) +  disp[2];
	love.graphics.setColor(self.color);
	if self.power then
		love.graphics.draw(self.img,self.quad,x,y,self.dir,(self.rad*2)/self.img:getWidth(),nil,self.img:getWidth()/2,self.img:getWidth()/2);
	else
		love.graphics.draw(self.img,self.quad,x,y,self.dir,(self.rad*4)/self.img:getWidth(),nil,self.img:getWidth()/4,self.img:getWidth()/4);
	end
	if self.id==1 or self.id==2 then
		if GAMEMNG.PSTATE[self.id].boost then
			love.graphics.draw(ASSET.sprites.fire,x - (math.cos(self.dir)*self.rad*scale),y - (math.sin(self.dir)*self.rad*scale),self.dir+(-math.pi/2),math.random(-1,1),-1*(((math.sin(GTIME*math.random())*0.5)+1)),ASSET.sprites.fire:getWidth()/2,0);
		end
		love.graphics.draw(ASSET.sprites.thruster,x - (math.cos(self.dir)*self.rad*scale),y - (math.sin(self.dir)*self.rad*scale),self.dir+(-math.pi/2),1,-1,ASSET.sprites.thruster:getWidth()/2,0);
	end
	GAMEMNG.drawState(self.id,x,y);
	love.graphics.setColor(mR,mG,mB,mA);--reapply old colors
end

function BALL.drawTrail(self,disp,scale)
	local mR,mG,mB,mA = love.graphics.getColor();--remember old colors	local x = (self.pos[1]*scale) +  disp[1];
	local disp = disp or {BALL.ballCenter[1] , BALL.ballCenter[2]}
	local scale = scale or BALL.ballScale;
	local x = (self.pos[1]*scale) +  disp[1];
	local y = (self.pos[2]*scale) +  disp[2];
	love.graphics.setColor(self.color);
	if self.power then
		love.graphics.draw(self.img,self.quad,x,y,self.dir,(self.rad-1)*2/self.img:getWidth(),nil,self.img:getWidth()/2,self.img:getWidth()/2);
	else
		love.graphics.draw(self.img,self.shadquad,x,y,self.dir,((self.rad-1)*4)/self.img:getWidth(),nil,self.img:getWidth()/4,self.img:getWidth()/4);
	end
	love.graphics.setColor(mR,mG,mB,mA);--reapply old colors
end

function BALL.del(self)
	table.insert(BALL.delQueue,self.id);
	self.deleted = true;
end

function BALL.cleanup()
	for k,v in pairs(BALL.delQueue) do
		if(BALL.list[v]) then
			if(BALL.list[v].player) then
				if(BALL.list[v].player < 0) then
					GAMEMNG.PSTATE[-BALL.list[v].player].bullets = GAMEMNG.PSTATE[-BALL.list[v].player].bullets - 1;
					BALL.list[v] = nil;
				end
			end
			if BALL.list[v].power then
				GAMEMNG.POWCOUNT = GAMEMNG.POWCOUNT - 1;
				if BALL.list[v].power == "flag" then
					GAMEMNG.FLAG = false;
					CONSOLE.log("flag died")
					BALL.list[v] = nil;
				end
			end
		end
		BALL.list[v] = nil;
	end
	BALL.delQueue = {};
end
BALL = {}
BALL.__index = BALL;

BALL.list={}-->>table that contains all balls

BALL.lastIndex=0;--Last index of BALL.list

BALL.G = 50 -->>Gravititational constant

BALL.ballScale = 1; --multiplyer for radius when drawing

BALL.ballCenter = V.vectorize{winW/2,winH/2}; --onscreen coords corresponding to 0,0 in game
BALL.cenTar = BALL.ballCenter; --centaurs (center target)
BALL.cenSpe = 500;
BALL.superJumpDist = 0.5;
BALL.pTimeMult = 1;
BALL.touchMass = 500; --mass of invisible ball spawned upon click
BALL.doPhysUp = true; --do updates for balls
BALL.tailLen = 0x01;

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

function BALL.new(x,y,rad,mass,color,lock,img,quadNum) -->> creates a new ball object, stores object in BALL.list, returns id of ball
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
	if not(rad==0) then
		self.img = img; --image the ball draws from
		quadNum = quadNum or (math.floor(math.random()*10)); --random 0 to 3. temporary randomizer
		self.quad = love.graphics.newQuad(0,self.img:getHeight()*quadNum*0.1,self.img:getWidth()/2,self.img:getHeight()*0.1,self.img:getDimensions());
		self.shadquad = love.graphics.newQuad(self.img:getWidth()/2,self.img:getHeight()*quadNum*0.1,self.img:getWidth()/2,self.img:getHeight()*0.1,self.img:getDimensions());
	end
	BALL.list[self.id] = self;
	return self.id;
end

function BALL.getNewID() -->>gets a new id for a new ball 'obj'
	local returnVal = 1;
	for i=1,BALL.lastIndex+1 do
		if not BALL.list[i] then returnVal = i end
		BALL.lastIndex = i;
	end
	return returnVal;
end


function BALL.update(self,dt)--UPDATE
	if self==nil or self.lock then return; end
	self.colCheck = {};
	self.hasCol = {};
	self.pos = self.pos + (self.vel*dt)
	self.vel = self.vel + (self.acc*dt);
	self.torsion = self.acc --current warp of ball (drawing-related)
	self.acc = V.vectorize({0,0}); --reset acceleration
	self.dir = self.dir+(dt*self.spin);
	if not(self.iFrames==0) then --update invincibility
		self.iFrames=self.iFrames-dt
	end
end

function BALL.doCollisions() -->>does collision check for all balls
	local bbi = nil; --big ball index
	local lbi = nil; --long beach island
	local mag = V.getMagnitude;
	local eat = BALL.eat;
	for i=1, BALL.lastIndex do
		for j=i+1, BALL.lastIndex do
			if BALL.list[i] and BALL.list[j] then
				if (not(BALL.list[i].colCheck[j] and BALL.list[j].colCheck[i])) and (BALL.list[i].iFrames==0 and BALL.list[j].iFrames==0)  then --AAAAAAAAAAAAAAAAAAAAAAAAAAAA
					--If the balls have not colided and neither ball has invincibility, although they shouldn'tve collieded. *shrug*
					if BALL.list[i].rad>=BALL.list[j].rad then
						bbi = i;
						lbi = j;
					else
						bbi = j;
						lbi = i;
					end
					
					if mag(BALL.list[i].pos-BALL.list[j].pos)<(BALL.list[bbi].rad) then --AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
						BALL.list[i].colCheck[j] = true;
						BALL.list[j].colCheck[i] = true;
						eat(BALL.list[i],BALL.list[j]);
					end
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
				
				if dist < BALL.list[i].rad or dist < BALL.list[j].rad then
					if BALL.list[i].rad > BALL.list[j].rad then
						dist = BALL.list[i].rad;
					else
						dist = BALL.list[j].rad;
					end
				end
				
				local force = (
					(BALL.G*BALL.list[i].mass*BALL.list[j].mass)
					/
					(dist*dist)
				);
				--calculates force divided by mass (acceleration)
				
				BALL.list[i].acc = BALL.list[i].acc + (dir*(force/BALL.list[i].mass)) --increase acc. by appropriate vector force
				BALL.list[j].acc = BALL.list[j].acc + (-1*dir*(force/BALL.list[j].mass)) --increase acc. by opposite vector force
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
		BALL.list[ball2.id]=nil; --destroy the second body
end

function BALL.draw(self,disp,scale)-->>call for painting ball
	local mR,mG,mB,mA = love.graphics.getColor();--remember old colors
	local disp = disp or {BALL.ballCenter[1] , BALL.ballCenter[2]};
	local scale = scale or BALL.ballScale;
	local x = math.floor(self.pos[1]*scale) +  disp[1];
	local y = math.floor(self.pos[2]*scale) +  disp[2];
	love.graphics.setColor(self.color);
	love.graphics.draw(self.img,self.quad,x,y,self.dir,self.rad*scale*4/self.img:getWidth(),self.rad*scale*4/self.img:getWidth(),self.img:getWidth()/4,self.img:getWidth()/4);
	love.graphics.setColor(mR,mG,mB,mA);--reapply old colors
end

function BALL.drawTrail(self,disp,scale)
	local mR,mG,mB,mA = love.graphics.getColor();--remember old colors
	local disp = disp or {BALL.ballCenter[1] , BALL.ballCenter[2]}
	local scale = scale or BALL.ballScale;
	local x = math.floor(self.pos[1]*scale) +  disp[1];
	local y = math.floor(self.pos[2]*scale) +  disp[2];
	love.graphics.setColor(self.color);
	love.graphics.draw(self.img,self.shadquad,x,y,self.dir,self.rad*scale*4/self.img:getWidth(),self.rad*scale*4/self.img:getWidth(),self.img:getWidth()/4,self.img:getWidth()/4);
	love.graphics.setColor(mR,mG,mB,mA);--reapply old colors
end 
GUI = {}

GUI.GUIBASE = {}
GUI.GUIBASE.__index = GUI.GUIBASE;
	function GUI.GUIBASE.new(guiType,dim,font,scale,title,img,quads,...)
		local args = {...}
		local self = {};
		self.x1 = dim[1];
		self.dX = dim[3];
		
		self.y1 = dim[2];
		self.dY = dim[4];
		
		self.textScale = scale;
		self.func = func;
		self.scale = scale;
		self.title = title;
		self.lock = false;
		self.label = self.title
	
		self.held = false;
		
		self.label = self.title;
		
		self.img = img;
		self.quads = quads;
		self.font = font or love.graphics.getFont();
		GUI[guiType].init(self, args);
		setmetatable(self,GUI[guiType]);
		return self;
	end

	function GUI.GUIBASE.update(self,acts)
		self:cycle();
		if not acts[1] then self.held = false; return; end
		
		local inbounds;
		for k,v in ipairs(acts) do
			if(self.x1<=acts[k][1] and self.y1<=acts[k][2] and self.dX+self.x1>=acts[k][1] and self.dY+self.y1>=acts[k][2]) then
				inbounds = k;
			end
		end
		if self.lock or not inbounds then self.held = false; return; end
		self:onClick(acts[inbounds]);
		table.remove(acts,inbounds);
		self.held = true;
	end
----------------------------------------------------------------------
GUI.SLIDER = {}
GUI.SLIDER.__index = GUI.SLIDER;
setmetatable(GUI.SLIDER,GUI.GUIBASE);

	function GUI.SLIDER.init(self, args)
	
		local parentTab = _G;
		local lastIndex = 0;
		local finalIndex = "";
		
		if type(args[2])=="table" then
			if args[2][2] then --variable is a child of another table
				for k,v in ipairs(args[2]) do
					if args[2][k+1] then
						parentTab = parentTab[args[2][k]];
						lastIndex = lastIndex + 1;
					else
						finalIndex = args[2][k];
						break;
					end
				end
			else
				parentTab = _G;
				finalInex = args[2][1];
			end
		else
		
		--Variable is a child of global
		parentTab = _G;
		finalIndex = args[2];
		
		end
	
		self.parentTable = parentTab
		self.varIndex = finalIndex;
		self.slideMin = args[1][1] or 1;
		self.slideMax = args[1][2] or 10;
		self.parentTable[self.varIndex] = args[1][3] or self.parentTable[self.varIndex]; 
		self.slideX = (self.dX*((self.parentTable[self.varIndex]-self.slideMin)/(self.slideMax-self.slideMin)))+self.x1; --GUI.SLIDER circle thingy
		
		self.slideY = ((2*self.y1+self.dY))*0.5;

		self.quads = quads or {
			love.graphics.newQuad(0,0,self.img:getWidth(),self.img:getHeight()*0.25,self.img:getDimensions()),
			love.graphics.newQuad(0,self.img:getHeight()*0.25,self.img:getWidth(),self.img:getHeight()*0.25,self.img:getDimensions()),
			love.graphics.newQuad(0,self.img:getHeight()*0.5,self.img:getWidth()*0.25,self.img:getHeight()*0.5,self.img:getDimensions()),
			love.graphics.newQuad(self.img:getWidth()*0.75,self.img:getHeight()*0.5,self.img:getWidth()*0.25,self.img:getHeight()*0.5,self.img:getDimensions())
			}
		setmetatable(self,GUI.SLIDER);
	end

	function GUI.SLIDER.render(self)
		local oldFont = love.graphics.getFont();
		love.graphics.setFont(self.font);
		
		love.graphics.print(self.label,self.x1,self.y1,0,self.textScale[1],self.textScale[2]);--prints label
		if self.held then
			love.graphics.draw(self.img,self.quads[1],self.x1,self.slideY-(self.img:getWidth()*0.0625),nil,self.dX/self.img:getWidth(),1);
			love.graphics.draw(self.img,self.quads[4],self.slideX-(self.img:getWidth()*0.0625),self.slideY-(self.img:getWidth()*0.125));--draws GUI.SLIDER	
		else
			love.graphics.draw(self.img,self.quads[2],self.x1,self.slideY-(self.img:getWidth()*0.0625),nil,self.dX/self.img:getWidth(),1);
			love.graphics.draw(self.img,self.quads[3],self.slideX-(self.img:getWidth()*0.125),self.slideY-(self.img:getWidth()*0.125));--draws GUI.SLIDER
		end
		love.graphics.setFont(oldFont);
	end

	function GUI.SLIDER.onClick(self,act)
		self.slideX = act[1];
		self.parentTable[self.varIndex] = (self.slideMax-self.slideMin)*((self.slideX-self.x1)/self.dX) + self.slideMin;
	end

	function GUI.SLIDER.cycle(self)
		self.label = self.title.."; "..self.parentTable[self.varIndex]; --sets value initially so return; checks don't interrupt update
		self.slideX = (self.dX*((self.parentTable[self.varIndex]-self.slideMin)/(self.slideMax-self.slideMin)))+self.x1;
	end
----------------------------------------------------------------------
GUI.TOGGLE = {}
GUI.TOGGLE.__index = GUI.TOGGLE
setmetatable(GUI.TOGGLE,GUI.GUIBASE);
	function GUI.TOGGLE.init(self,args)
		local parentTab = _G;
		local lastIndex = 0;
		local finalIndex = "";
		if type(args[2])=="table" then
			if args[2][2] then --variable is a child of another table
				for k,v in ipairs(args[2]) do
					if args[2][k+1] then
						parentTab = parentTab[args[2][k]];
						lastIndex = lastIndex + 1;
					else
						finalIndex = args[2][k];
						break;
					end
				end
			else
				parentTab = _G;
				finalInex = args[2][1];
			end
		else
		--Variable is a child of global
		parentTab = _G;
		finalIndex = args[2];
		end
		self.parentTable = parentTab
		self.varIndex = finalIndex;
		self.quads = quads or {
			love.graphics.newQuad(0,0,self.img:getWidth(),self.img:getHeight()*0.5,self.img:getDimensions()),
			love.graphics.newQuad(0,self.img:getHeight()*0.5,self.img:getWidth(),self.img:getHeight()*0.5,self.img:getDimensions())
			}
		self.parentTable[self.varIndex] = value or self.parentTable[self.varIndex];
		setmetatable(self,GUI.TOGGLE);
		self.label = self.title.."; "..tostring(self.parentTable[self.varIndex]);
		return self;
	end

	function GUI.TOGGLE.render(self)
		local oldFont = love.graphics.getFont();
		love.graphics.setFont(self.font);
		if not self.parentTable[self.varIndex] then
			love.graphics.draw(self.img,self.quads[2],self.x1,self.y1,nil,self.dX/self.img:getWidth(),self.dY/(self.img:getHeight()*0.5));
			love.graphics.print(self.label,self.x1,self.y1,0,self.scale[1],self.scale[2]);
		else
			love.graphics.draw(self.img,self.quads[1],self.x1,self.y1,nil,self.dX/self.img:getWidth(),self.dY/(self.img:getHeight()*0.5));
			local oldC = {love.graphics.getColor()};
			love.graphics.setColor(255-oldC[1],255-oldC[2],255-oldC[3],oldC[4]);
			love.graphics.print(self.label,self.x1,self.y1,0,self.scale[1],self.scale[2]);
			love.graphics.setColor(oldC);
		end
	
		love.graphics.setFont(oldFont);
	end
	
	function GUI.TOGGLE.onClick(self,act)
		if self.held then return; end	
		self.parentTable[self.varIndex] = not self.parentTable[self.varIndex];
	end
	function GUI.TOGGLE.cycle(self)
		self.label = self.title.."; "..tostring(self.parentTable[self.varIndex]);
	end
	
----------------------------------------------------------------------
GUI.BUTTON = {}
GUI.BUTTON.__index = GUI.BUTTON;
setmetatable(GUI.BUTTON,GUI.GUIBASE);
	
	function GUI.BUTTON.init(self,args)
		self.func = args[1]
		self.quads = quads or {
			love.graphics.newQuad(0,0,self.img:getWidth(),self.img:getHeight()*0.5,self.img:getDimensions()),
			love.graphics.newQuad(0,self.img:getHeight()*0.5,self.img:getWidth(),self.img:getHeight()*0.5,self.img:getDimensions())
			}
	end

	function GUI.BUTTON.render(self)
		local oldFont = love.graphics.getFont();
		love.graphics.setFont(self.font);
		if not self.held then
			love.graphics.draw(self.img,self.quads[2],self.x1,self.y1,nil,self.dX/self.img:getWidth(),self.dY/(self.img:getHeight()*0.5));
			love.graphics.print(self.label,self.x1,self.y1,0,self.scale[1],self.scale[2]);
		else
			love.graphics.draw(self.img,self.quads[1],self.x1,self.y1,nil,self.dX/self.img:getWidth(),self.dY/(self.img:getHeight()*0.5));
			local oldC = {love.graphics.getColor()};
			love.graphics.setColor(255-oldC[1],255-oldC[2],255-oldC[3],oldC[4]);
			love.graphics.print(self.label,self.x1,self.y1,0,self.scale[1],self.scale[2]);
			love.graphics.setColor(oldC);
		end
		love.graphics.setFont(oldFont);
	end
	
	function GUI.BUTTON.onClick(self)
		self.label = self.title;
		self.func(self.held);
	end
	function GUI.BUTTON.cycle(self)
		--owo
	end
-------------------------------------------------------------------------------------

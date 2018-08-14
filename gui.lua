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
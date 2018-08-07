MENU = {};
MENU.currentMenu = {};

function MENU.load(string)
	--MENU.currentMenu = string;
	local data = JSON.decode(string);
	for i,obj in ipairs(data) do
		for k,v in pairs(obj) do
			if type(v)=="string" and not(k == "title" or k=="type" or k=="varStr") then
				obj[k] = load("return "..v)();
			end
		end
		MENU.currentMenu[i] = GUI[obj.type].new(obj.type,obj.pos,obj.font,obj.fntSCL,obj.title,obj.img,obj.quads,obj.val,obj.varStr);
	end
end

function MENU.unload()-->> unloads data
	MENU.currentMenu = {};
end

function MENU.render()
	for i,obj in ipairs(MENU.currentMenu) do
		obj:render();
	end
end

function MENU.update()
	for i,obj in ipairs(MENU.currentMenu) do
		obj:update(TOUCHES);
	end
end

function MENU.find(title)
	for i,obj in ipairs(MENU.currentMenu) do
		if obj.title == title then
			return MENU.currentMenu[i];
		end
	end
end
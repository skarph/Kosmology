ASSET = {};
ASSET.__DIR = "assets";
ASSET.__EXT = {};
ASSET.__EXT.MUSIC = {"wav","mp3"};
ASSET.__EXT.SOUND = {"ogg"}
ASSET.__EXT.GRAPHIC = {"png","jpg"};
ASSET.__EXT.FONT = {"ttf"};
ASSET.__EXT.LEVEL = {"json"};

function ASSET.__getType(ext)
	for k,v in pairs(ASSET.__EXT) do
		for j,w in ipairs(ASSET.__EXT[k]) do
			if w == ext then
				return k;
			end
		end
	end
	return nil;
end

function ASSET.load(p,upTable)--recursively loads all assets in path or main directory. Leave upTable nil, used for recursive calling
	
	local path = p or ASSET.__DIR;
	local dirList = love.filesystem.getDirectoryItems(path);
	local upTable = upTable or ASSET;
	
	for k, rPath in ipairs(dirList) do
		
		if love.filesystem.isDirectory(path.."/"..rPath) then
			upTable[rPath] = {}
			ASSET.load(path.."/"..rPath,upTable[rPath]);--go one folder down
		else
			
			local ext = rPath:sub(rPath:find('%.')+1,rPath:len());
			local indexName = rPath:sub(1,rPath:find('%.')-1);
			local dataType = ASSET.__getType(ext);
			--Determine/Load asset
			if dataType == "SOUND" then
				upTable[indexName] = love.audio.newSource(path.."/"..rPath,"static");
			elseif dataType == "MUSIC" then
				upTable[indexName] = love.audio.newSource(path.."/"..rPath,"stream");
			elseif dataType == "GRAPHIC" then
				upTable[indexName] = love.graphics.newImage(path.."/"..rPath);
			elseif dataType == "FONT" then
				upTable[indexName] = love.graphics.newFont(path.."/"..rPath);
			elseif dataType == "LEVEL" then
				upTable[indexName] = love.filesystem.read(path.."/"..rPath);
			end
			
		end
	end
	
end

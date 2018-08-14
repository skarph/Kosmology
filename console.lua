CONSOLE = {};
CONSOLE.LIST = {};
CONSOLE.VALS = {};
CONSOLE.LEN = 10;

function CONSOLE.log(...)
 	local args = {...};
 	local str = "";
 	for i = 1, #args do
 		if i==#args then
 			str = str .. args[i];
 		else
 			str = str .. args[i] .. " , ";
 		end
 	end
 	CONSOLE.shove(str);
end

function CONSOLE.shove(str)
	for i = CONSOLE.LEN, 1, -1  do
		CONSOLE.LIST[i] = CONSOLE.LIST[i - 1] or str;
	end
end

function CONSOLE.getString()
	local str = ""
	for i = 1, CONSOLE.LEN  do
		if not CONSOLE.LIST[i] then
			CONSOLE.LIST[i] = "";
		end
		str = str.."\n".."["..i.."]: "..CONSOLE.LIST[i];
	end
	str = str .. "\n=========="
	for k,v in pairs(CONSOLE.VALS) do
		if CONSOLE.VALS[k] then
			str = str.."\n".."["..k.."]: "..CONSOLE.VALS[k]
		end
	end
	return str;
end

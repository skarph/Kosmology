V = {};
V.__index = V;

function V.vectorize(table)-->>Takes input as a table-indexed-array, return a formated table with a count for dimmensions and a confirm that the table is the factor
	local vectorTable = table;
	if vectorTable.ISVECTOR then
		error(tostring(vectorTable).."is already vectorized!");
	end
	local dimCount = 0
	
	for k,v in ipairs(vectorTable) do
		if not(type(v)=='number') then
			error(tostring(vectorTable).."contains a non-number value!");
			dimCount = dimCount+1;
		end
	
		dimCount = dimCount+1
	end
	
	vectorTable.ISVECTOR = true
	vectorTable.DIMCOUNT = dimCount;
	setmetatable(vectorTable,V);
	return vectorTable;
end

function V.__add(op1,op2)-->>add vectors
	local value = {};
	if not(getmetatable(op1)==getmetatable(op2)) then error("Both tables must be vector-formated! [V.vectorize("..tostring(op1)..")]") end --check both vectors
	if not(op1.DIMCOUNT==op2.DIMCOUNT) then error("Tables do not have equal dimmensions!"); end
	for i=1,op1.DIMCOUNT do
		value[i] = op1[i]+op2[i]; --add each
	end
	return V.vectorize(value);--vectorize table
end

function V.__sub(op1,op2)-->>subtract vectors
	local value = {};
	if not(getmetatable(op1)==getmetatable(op2)) then error("Both tables must be vector-formated! [V.vectorize("..tostring(op1)..")]") end
	if not(op1.DIMCOUNT==op2.DIMCOUNT) then error("Tables do not have equal dimmensions!"); end
	for i=1,op1.DIMCOUNT do
		value[i] = op1[i]-op2[i];
	end
	return V.vectorize(value);
end

function V.__mul(op1,op2)-->>multiply vectors by vector/scalar
	local value = {};
	if type(op2)=='number' then --scalar
		for i=1,op1.DIMCOUNT do
			value[i] = op1[i]*op2
		end
		return V.vectorize(value);
	elseif type(op1)=='number' then --scalar
		for i=1,op2.DIMCOUNT do
			value[i] = op2[i]*op1
		end
		return V.vectorize(value);
	elseif getmetatable(op1)==getmetatable(op2) then
		if not(op1.DIMCOUNT==op2.DIMCOUNT) then error("Tables do not have equal dimmensions!"); end
		for i=1,op1.DIMCOUNT do
			value[i] = op1[i]*op2[i];
		end
		return V.vectorize(value);
	elseif op2.ISMATRIX then
		return M.__mul(op1,op2);
	end
end

function V.__div(op1,op2)-->>divide vectors/scalar
	local value = {};
	if type(op2)=='number' then
		for i=1,op1.DIMCOUNT do
			value[i] = op1[i]/op2;
		end
		return V.vectorize(value);
	elseif type(op1)=='number' then
		for i=1,op2.DIMCOUNT do
			value[i] = op2[i]/op1;
		end
		return V.vectorize(value);
	elseif getmetatable(op1)==getmetatable(op2) then
		if not(op1.DIMCOUNT==op2.DIMCOUNT) then error("Tables do not have equal dimmensions!"); end
		for i=1,op1.DIMCOUNT do
			value[i] = op1[i]/op2[i];
		end
		return V.vectorize(value);
	elseif op2.ISMATRIX then
		return M.__div(op1,op2);
	end
end

function V.__eq(op1,op2)
	if not(getmetatable(op1)==getmetatable(op2)) then error("Both tables must be vector-formated! [V.vectorize("..tostring(op1)..")]"); end
	if not(op1.DIMCOUNT==op2.DIMCOUNT) then return false; end
	for i=1,op1.DIMCOUNT do
		if not(op1[i]==op2[i]) then return false; end
	end
	return true;
end

function V.norm(self)-->>normalize Victor
	local magnitude = self:getMagnitude();
	if magnitude == 0 then
		return V.vectorize({0,0});
	end
	return (self/magnitude);--sad.
end

function V.getMagnitude(self)
	local magnitude = 0;
	for i=1, self.DIMCOUNT do
		magnitude = magnitude + math.pow(self[i],2); --recursively add
	end
	magnitude = math.sqrt(magnitude); --take root, dist. formula
	return magnitude;
end

function V.distTo(op1,op2)
	if not(getmetatable(op1)==getmetatable(op2)) then error("Both tables must be vector-formated! [V.vectorize("..tostring(op1)..")]"); end;
	if not(op1.DIMCOUNT==op2.DIMCOUNT) then return nil; end;
	local dist = 0;
	if(op1.DIMCOUNT==1) then
		return V.vectorize{math.abs(op1[1]-op2[2])};
	end
	for i=1, op1.DIMCOUNT do
		dist = dist + (math.abs(math.pow(op1[i]-op2[i],2)));
	end
	dist = math.sqrt(dist);
	return dist;
end

function V.dot(op1,op2)
	if not(getmetatable(op1)==getmetatable(op2)) then error("Both tables must be vector-formated! [V.vectorize("..tostring(op1)..")]"); end;
	if not(op1.DIMCOUNT==op2.DIMCOUNT) then return nil; end;
	local dotprod = 0
	for i=1, op1.DIMCOUNT do
		dotprod = dotprod + (op1[i] * op2[i]);
	end
	return dotprod
end

------------------------------------------------------------------------------------
M = {};
M.__index = M;

function M.new(intab,x,y)
	local matrix = intab;
	
	local xDim = 0;
	local yDim = 0;
	
	if (not intab) and x and y then
		
		matrix = {};
		for i=1,x+1 do
			matrix[i] = {};
			for j=1, y+1 do
				matrix[i][j] = {};
			end
		end
	elseif intab then
		
		for k,v in ipairs(intab) do
			xDim = xDim + 1;
			for m,p in ipairs(intab[k]) do
				if xDim == 1 then
					yDim = yDim + 1;
				end
				if not intab[xDim][yDim] then
					intab[xDim][yDim] = {};
				end
			end
		end
	else
		error("not good duud");
	end

	if matrix.ISMATRIX then
		error(tostring(vectorTable).."is already a matrix!");
	end
	
	matrix.ISMATRIX = true
	matrix.xDIM = xDim;
	matrix.yDIM = yDim;

	setmetatable(matrix,M);
	return matrix;
end

function M.__add(op1,op2)-->>add vectors
	if not(getmetatable(op1)==getmetatable(op2)) then error("Both tables must be matrix-formated!") end
	if not(op1.xDIM==op2.xDIM) or not(op1.yDIM==op2.xDIM) then error("Tables do not have equal dimmensions!"); end
	
	local matrix = M.new(nil,op1.xDIM,op1.yDIM);
	
	for k,v in ipairs(op1) do
		for m,j in ipairs(op1[k]) do
			matrix[k][m] = op1[k][m] + op2[k][m];
		end
	end
	return matrix;
end

function M.__sub(op1,op2)-->>subtract vectors
	if not(getmetatable(op1)==getmetatable(op2)) then error("Both tables must be matrix-formated!") end
	if not(op1.xDIM==op2.xDIM) or not(op1.yDIM==op2.xDIM) then error("Tables do not have equal dimmensions!"); end
	
	local matrix = M.new(nil,op1.xDIM,op1.yDIM);
	
	for k,v in ipairs(op1) do
		for m,j in ipairs(op1[k]) do
			matrix[k][m] = op1[k][m] - op2[k][m];
		end
	end
	return matrix;
end

function M.__mul(op1,op2)-->>multiply vectors by vector/scalar
	local value = nil
	
	if type(op2)=='number' then --scalar
		value = M.new(nil,op1.xDIM,op1.yDIM);
		for k,v in ipairs(op1) do
			for m,j in ipairs(op1[k]) do
				value[k][m] = op2 * op1[k][m];
			end
		end
		return value;
	elseif type(op1)=='number' then --scalar
		value = M.new(nil,op2.xDIM,op2.yDIM);
		for k,v in ipairs(op2) do
			for m,j in ipairs(op2[k]) do
				value[k][m] = op1 * op2[k][m];
			end
		end
		return value;
	elseif op1.ISVECTOR then
		if op1.DIMCOUNT == op2.yDIM then
			value = {};
			for k,v in ipairs(op2) do
				value[k] = 0;
				for m,j in ipairs(op2[k]) do
					value[k] = value[k] + (op1[k] * op2[k][m]);
				end
			end
		return V.vectorize(value);
		else error("Matrix and Vector do not have equal dimmensions!"); end

	elseif op2.ISVECTOR then
	    if op2.DIMCOUNT == op1.yDIM then
			value = {};
			for k,v in ipairs(op1) do
				value[k] = 0;
				for m,j in ipairs(op1[k]) do
					value[k] = value[k] + (op2[m] * op1[k][m]);
					print("["..k..","..m.."]", op2[m].." x "..op1[k][m].." = "..(op2[k] * op1[k][m]));
				end
				print("val at "..k, value[k].."\n");
			end
			return V.vectorize(value);
		else error("Matrix and Vector do not have equal dimmensions!"); end

	elseif getmetatable(op1)==getmetatable(op2) then
		if op1.xDIM==op2.yDIM and op1.yDIM==op2.yDIM then
			value = M.new(nil,op1.xDIM,op1.yDIM);
			for k,v in ipairs(op1) do
				for m,j in ipairs(op1) do
					value[k][m] = op1[k][m] * op2[k][m];
				end
			end
		end
		return value;
	end
end

function M.__div(op1,op2)-->>multiply vectors by vector/scalar
	local value = nil
	
	if type(op2)=='number' then --scalar
		value = M.new(nil,op1.xDIM,op1.yDIM);
		for k,v in ipairs(op1) do
			for m,j in ipairs(op1[k]) do
				value[k][m] = op1[k][m] / op2;
			end
		end
		return value;
	elseif type(op1)=='number' then --scalar
		value = M.new(nil,op2.xDIM,op2.yDIM);
		for k,v in ipairs(op2) do
			for m,j in ipairs(op2[k]) do
				value[k][m] = op1 / op2[k][m];
			end
		end
		return value;
	elseif op1.ISVECTOR then
		if op1.DIMCOUNT == op2.yDIM then
			value = {};
			for k,v in ipairs(op2) do
				value[k] = 0;
				for m,j in ipairs(op2[k]) do
					value[k] = value[k] + (op1[k] / op2[k][m]);
				end
			end
		return V.vectorize(value);
		else error("Matrix and Vector do not have equal dimmensions!"); end

	elseif op2.ISVECTOR then
	    if op2.DIMCOUNT == op1.yDIM then
			value = {};
			for k,v in ipairs(op1) do
				value[k] = 0;
				for m,j in ipairs(op1[k]) do
					value[k] = value[k] + (op1[k][m] / op2[k]);
				end
			end
			return V.vectorize(value);
		else error("Matrix and Vector do not have equal dimmensions!"); end

	elseif getmetatable(op1)==getmetatable(op2) then
		if op1.xDIM==op2.yDIM and op1.yDIM==op2.yDIM then
			value = M.new(nil,op1.xDIM,op1.yDIM);
			for k,v in ipairs(op1) do
				for m,j in ipairs(op1) do
					value[k][m] = op1[k][m] / op2[k][m];
				end
			end
		end
		return value;
	end
end
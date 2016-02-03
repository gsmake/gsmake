local package = package
local debug = debug

local function create_loader(filename)
	local f,err = loadfile(filename)
	if f == nil then
		return err
	end
	return function()
		return {
			["__lemoon_requirex"] = function(env)
				if env then
					debug.setupvalue(f, 1, env)
				end

				return f()
			end;
		}
	end
end

local function searcher(name)
	
	local filename, err = package.searchpath(name, package.spath or "")
	if filename == nil then
		return err
	else
		return create_loader(filename)
	end
end

table.insert(package.searchers, searcher)

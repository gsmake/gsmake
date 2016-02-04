-- initialize gsmake's sandbox system

local debug = _G.debug
local throw = require "lemoon.throw"

local function createlualoader(filename)
	local f,err = loadfile(filename)
	if f == nil then
		return err
	end
	return function()
		return {

            ["__sandbox"] = function(env)
                 if env then
                     debug.setupvalue(f, 1, env)
                 end
                 return f()
             end
         }
	end
end

-- lua searcher
local function luasearcher(name)

	local filename, err = package.searchpath(name, package.path or "")
	if filename == nil then
		return err
	else
		return createlualoader(filename)
	end
end

local function resetloaded(loaded)
    local recover = {}

    for k,v in pairs(_G.package.loaded) do
        recover[k] = v
        _G.package.loaded[k] = nil
    end

    for k,v in pairs(loaded) do
        _G.package.loaded[k] = v
    end

    return recover
end

local preload = resetloaded(_G.package.loaded)

local sandbox = {}

function sandbox.new(name,...)

    local env = {}

    for k,v in pairs(_G) do
        env[k] = v
    end

    env.package         = {}

    for k,v in pairs(_G.package) do
        env.package[k] = v
    end

    env.package.loaded      = preload
    env.package.preload     = {}
    env.package.searchers   = { luasearcher }

    -- create new require
    env.require = function(name)

        local idx = 1
        while true do
            local name,val = debug.getupvalue(luasearcher,idx)
            if not name then break end

            if name == "_ENV" then
                debug.setupvalue(luasearcher,idx,env)
                break
            end

            idx = idx + 1
        end

        local reconver = resetloaded(env.package.loaded)
        debug.setupvalue(_G.require,1,env.package)
        local block = _G.require(name)
        env.package.loaded = resetloaded(reconver)

        if type(block) == "table" and type(block["__sandbox"]) == "function" then
            block = block["__sandbox"](env)
        end

        return block
    end

    if name then
        require(name).ctor(env,...)
    end

    -- create sandbox env cached buff
    sandbox[env] = {}

    return env
end

local function runfunction(call,env,...)
	local idx = 1
	while true do
        local name,_ = debug.getupvalue(call, idx)

        if not name then break end

        if name == "_ENV" then
            debug.setupvalue(call,idx,env)
            break
        end

        idx = idx + 1
    end

	return call(...)
end

local function runscript(script,env)
	 local block,err = loadfile(script,"bt",env)

	 if err ~= nil then
        throw(err)
     end

    return block()
end

function sandbox.run(block,env,...)
	if type(block) == "function" then
		runfunction(block,env,...)
	else
		runscript(block,env,...)
	end
end

_G.sandbox = sandbox

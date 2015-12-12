local class     = require "lemoon.class"
local class     = require "lemoon.class"

local logger    = class.new("lemoon.log","lake")

local module = {}

local function loadScript(script,env)
    local closure,err = loadfile(script,"bt",env)

    if err ~= nil then
        error(string.format("load plugin -- failed,%s",err))
    end

    return closure()
end

function module.ctor(sandbox,...)
    local obj = {
        originPath      = _ENV.package.path;
        originCPath     = _ENV.package.cpath;
        originLoaded    = class.clone(_ENV.package.loaded);
        env             = class.clone(_ENV);
    }

    require(sandbox).ctor(obj.env,...)

    assert(obj.env.package == _ENV.package,string.format("sandbox(%s) modified variable(package) : not allow",sandbox))

    return obj
end

function module:call(F,...)
    self.env,_ENV = _ENV,self.env
    local ret = { pcall(F,...) }
    self.env,_ENV = _ENV,self.env

    _ENV.package.path = self.originPath
    _ENV.package.cpath = self.originCPath

    for k in pairs(_ENV.package.loaded) do
        if self.originLoaded[k] == nil then
            _ENV.package.loaded[k] = nil
        end
    end

    if not ret[1] then
        error("\n\t" .. ret[2],2)
    end

    return table.unpack(ret,2)
end

function module:run(script)

    local ret = { pcall(loadScript,script,self.env) }

    _ENV.package.path = self.originPath
    _ENV.package.cpath = self.originCPath

    for k in pairs(_ENV.package.loaded) do
        if self.originLoaded[k] == nil then
            _ENV.package.loaded[k] = nil
        end
    end

    if not ret[1] then
        error("\n\t" .. ret[2],2)
    end

    return table.unpack(ret,2)
end


return module

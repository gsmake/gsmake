require "lemoon.requirex"

local throw     = require "lemoon.throw"
local class     = require "lemoon.class"

local logger    = class.new("lemoon.log","lake")

local module = {}

local function loadScript(script,env)
    local closure,err = loadfile(script,"bt",env)

    if err ~= nil then
        throw("load plugin -- failed\n\t%s",err)
    end

    return closure()
end

local function sandbox_call(env,call,...)
    local loaded    = class.clone(package.loaded)
    local path      = package.path
    local cpath     = package.cpath
    package.path    = ""
    package.cpath   = ""
    package.spath   = env.spath
    package.scpath  = env.scpath

    for k,_ in pairs(package.loaded) do
        if _G[k] == nil then
            package.loaded[k] = nil
        end
    end

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

    local return_args = table.pack(pcall(call,...))

    package.path    = path
    package.cpath   = cpath
    package.spath   = ""
    package.scpath  = ""


    for k,_ in pairs(package.loaded) do
        package.loaded[k] = nil
    end

    for k,v in pairs(loaded) do
        package.loaded[k] = v
    end

    if not return_args[1] then
        throw(return_args[2])
    end

    return table.unpack(return_args,2)
end

function module.ctor(sandbox,...)
    local obj = {
        env         = class.clone(_ENV);
    }

    setmetatable(obj.env,nil)

    for k,_ in pairs(obj.env) do
        if _G[k] == nil then
            obj.env[k] = nil
        end
    end

    obj.env.require = function(name)

        local block = _G.require(name)

        if type(block) == "table" and block["__lemoon_requirex"] ~= nil then
            block = block["__lemoon_requirex"](obj.env)

            return block
        end

        return block
    end

    obj.env.spath = package.path
    obj.env.scpath = package.cpath

    if obj.env.spath == "" then
        obj.env.spath = package.spath
    end

    if obj.env.scpath == "" then
        obj.env.scpath = package.scpath
    end

    sandbox_call(obj.env,function (...)
        require(sandbox).ctor(obj.env,...)
        obj.env.spath = obj.env.package.spath
        obj.env.scpath = obj.env.package.scpath
    end,...)

    return obj
end

function module:call(F,...)
    return sandbox_call(self.env,function(...)
        return F(...)
    end,...)
end

function module:run(script)
    return sandbox_call(self.env,function ()

        local block,err = loadfile(script,"bt",self.env)

        if err ~= nil then
            throw(err)
        end

        return block()
    end)
end


return module

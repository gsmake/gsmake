local throw = require "lemoon.throw"
local class = require "lemoon.class"

-- cached logger
local logger = class.new("lemoon.log","gsmake")

local module = {}

function module.ctor(env,package)

    env.lake = package.lake

    env.name = function(name)
        package.Name = name
    end

    env.version =  function(version)
        package.Version = version
    end

    env.plugin = function(name)
        local plugin = class.new("lake.plugin",name,package)
        package.Plugins[name] = plugin
        return plugin
    end

    env.task = {}

    local task_metatable = {
        __index = function(_,name)
            return package.Tasks[name]
        end;

        __newindex = function(_,name,F)
            assert(type(F) == "function","the input F must be a function")

            package.Tasks[name] = {
                Lake            = package.lake;
                Name            = name;
                F               = F;
                Package         = package;
                Owner           = package;
                Desc            = "";
            }
        end;
    }

    setmetatable(env.task,task_metatable)

    local hidenval = {}

    for name in pairs(env) do
        table.insert(hidenval,name)
    end

    setmetatable(env,{
        __newindex = function(_,name,val)

            for _,hiden in pairs(hidenval) do
                if hiden  == name then
                    throw("don't modify system variable '%s'",name)
                end
            end

            package.Properties[name] = val
        end
    })

end


return module

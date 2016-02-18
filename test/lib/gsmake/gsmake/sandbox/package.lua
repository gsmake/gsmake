local throw = require "lemoon.throw"
local class = require "lemoon.class"

-- cached logger
local logger = class.new("lemoon.log","gsmake")

local module = {}

function module.ctor(env,package)

    env.gsmake = package.Loader.GSMake

    env.name = function(name)
        package.Name = name
    end

    env.version =  function(version)
        package.Version = version
    end

    env.plugin = function(name)
        local plugin = class.new("gsmake.plugin",name,package)

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
                GSMake          = package.Loader.GSMake;
                Name            = name;
                Desc            = "";
                Package         = package;
                Owner           = package; -- self loader
                F               = F;
            }
        end;
    }

    setmetatable(env.task,task_metatable)

    env.properties = {}

    local properties_metatable = {
        __index = function(_,name)
            return package.Properties[name]
        end;

        __newindex = function(_,name,val)
            assert(type(val) == "table","the input property must be a table")
            package.Properties[name] = val
        end;
    }

    setmetatable(env.properties,properties_metatable)


    local hidenval = {"task","properties"}

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

            rawset(env,name,val)
        end
    })

end


return module

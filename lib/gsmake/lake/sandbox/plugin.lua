local sys   = require "lemoon.sys"
local class = require "lemoon.class"

local logger = class.new("lemoon.log","clang")


local module = {}

function module.ctor(env,plugin,path)

    env.task = {}

    local task_metatable = {
        __index = function(_,name)
            return plugin.Tasks[name]
        end;

        __newindex = function(_,name,F)
            assert(type(F) == "function","the input F must be a function")

            plugin.Tasks[name] = {
                Name            = name;
                F               = F;
                Owner           = plugin.Owner;
                Package         = plugin.Package;
                Desc            = "";
            }
        end;
    }

    setmetatable(env.task,task_metatable)

    env.plugin = plugin


    env.package.path = string.format("%s;%s/?.lua",env.package.path,path)
    env.package.cpath = string.format("%s;%s/?%s",env.package.cpath,path,sys.SO_NAME)

end


return module

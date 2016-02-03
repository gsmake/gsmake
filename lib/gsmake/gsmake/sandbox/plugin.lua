local sys   = require "lemoon.sys"
local class = require "lemoon.class"


local module = {}

function module.ctor(env,plugin,path)

    env.task = {}

    env.loader = plugin.Loader

    env.package.spath = string.format("%s;%s/gsmake/?.lua;%s/gsmake/?/init.lua;%s/lib/?.lua;%s/lib/?/init.lua",env.package.spath,path,path,path,path)
    -- env.package.cpath = string.format("%s;%s/?%s",env.package.cpath,path,sys.SO_NAME)

    local task_metatable = {
        __index = function(ctx,name)
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
                Path            = path;
            }
        end;
    }

    setmetatable(env.task,task_metatable)

end


return module

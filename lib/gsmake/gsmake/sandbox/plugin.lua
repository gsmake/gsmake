local sys   = require "lemoon.sys"
local class = require "lemoon.class"


local module = {}

function module.ctor(env,plugin,path)

    env.task = {}

    env.loader = plugin.Loader

    env.package.path = string.format("%s;%s/gsmake/?.lua;%s/gsmake/?/init.lua;%s/lib/?.lua;%s/lib/?/init.lua",env.package.path,path,path,path,path)

    if sys.host() == "Windows" then
        env.package.cpath = string.format("%s;%s/bin/?.dll",env.package.cpath,path)
    elseif sys.host() == "OSX" then
        env.package.cpath = string.format("%s;%s/bin/?.dylib",env.package.cpath,path)
    else
        env.package.cpath = string.format("%s;%s/lib/?.so",env.package.cpath,path)
    end

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

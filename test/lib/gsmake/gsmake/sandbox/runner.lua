local sys   = require "lemoon.sys"
local class = require "lemoon.class"

local module = {}

function module.ctor(env,task)

    if path then
        env.package.path = string.format("%s;%s/?.lua",env.package.path,task.Path)
    end

end


return module

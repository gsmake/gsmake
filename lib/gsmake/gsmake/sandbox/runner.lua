local sys   = require "lemoon.sys"
local class = require "lemoon.class"

local module = {}

function module.ctor(env,path)

    if path then
        env.package.spath = string.format("%s;%s/?.lua",env.package.spath,path)
    end

end


return module

local sys       = require "lemoon.sys"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

local logger    = class.new("lemoon.log","lake")

local module = {}

function module.ctor(env,lake,path)

    env.lake = lake
    env.package.path = string.format("%s;%s/?.lua",env.package.path,filepath.toslash(path))
    env.package.cpath = string.format("%s;%s/?%s",env.package.cpath,filepath.toslash(path),sys.SO_NAME)

end

return module

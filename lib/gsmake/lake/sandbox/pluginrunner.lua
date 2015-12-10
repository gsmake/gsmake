local sys       = require "lemoon.sys"
local filepath  = require "lemoon.filepath"

local module = {}

function module.ctor(env,path)

    env.package.path = string.format("%s;%s/?.lua",env.package.path,filepath.toslash(path))
    env.package.cpath = string.format("%s;%s/?%s",env.package.cpath,filepath.toslash(path),sys.SO_NAME)

end

return module

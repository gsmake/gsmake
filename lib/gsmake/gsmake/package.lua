local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local module    = {}

local logger    = class.new("lemoon.log","gsmake")

function module.ctor (loader,path,name,version)
    local package =
    {
        Loader      = loader                                         ;
        Name        = name                                           ;
        Version     = version or loader.Config.DefaultVersion        ;
        Path        = path                                           ;
        Plugins     = {}                                             ; -- package scope register plugins
        Tasks       = {}                                             ; -- package scope register tasks
        Properties  = {}                                             ; -- package scrope properties
    }

    -- do real package load
    local gsmakeFilePath = filepath.join(path,loader.Config.PackageFileName)

    if fs.exists(gsmakeFilePath) then
        logger:D("loading gsmake package\n\t%s",gsmakeFilePath)
        -- local sandbox = class.new("lemoon.sandbox","gsmake.sandbox.package",package)
        local env = sandbox.new("gsmake.sandbox.package",package)
        sandbox.run(gsmakeFilePath,env)
        logger:D("load gsmake package -- success\n\t%s",gsmakeFilePath)
    else
        package.External = true
    end

    return package
end

return module

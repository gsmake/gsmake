local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

local logger    = class.new("lemoon.log","gsmake")
local console   = class.new("lemoon.log","console")

local module    = {} -- the gsmake package loader object

-- create new package loader
-- @arg gsmake      the gsmake runtimes root object
-- @arg path        package load path
-- @arg name        package default name
-- @arg version     package default version
function module.ctor (gsmake,path,name,version)

    local loader = {
        GSMake      =  gsmake                           ;  -- the gsmake runtimes root object
        Config      =  class.clone(gsmake.Config)       ;  -- the loader's local config
        Path        =  path                             ;  -- gsmake loader workspace
    }

    loader.Temp =  filepath.join(path,gsmake.Config.TempDirName)

    -- create temp directory
    if not fs.exists(loader.Temp) then
        fs.mkdir(loader.Temp,true)
    end

    -- load config
    module.loadconfig(loader)
    -- load loader db
    loader.DB   = class.new("gsmake.loaderdb",loader,loader.Temp)
    -- load loader's sync engine
    loader.Sync =  class.new("gsmake.sync",loader)

    loader.Package = class.new("gsmake.package",loader,path,name,version)

    return loader
end

function module:loadconfig()

    local path = filepath.join(self.Path,self.GSMake.Config.ConfigFileName)

    if fs.exists(path) then
        local sandbox   = class.new("lemoon.sandbox","gsmake.sandbox.config",obj)
        local config    = sandbox:run(localConfigPath)

        for k,v in pairs(config) do
            if type(v) == "function" then
                self.Config[k] = sandbox:call(v)
            else
                self.Config[k] = v
            end
        end
    end
end

function module:load()
    local package = self.Package

    for name,plugin in pairs(package.Plugins) do

        plugin:load()
    end

    return package
end

function module:setup()

    local package = self.Package

    for _,plugin in pairs(package.Plugins) do
        plugin:setup()
    end

    self.runner = class.new("gsmake.runner",self.Package)
end

function module:run(...)
    self.runner:run(...)
end


return module

local fs        = require "lemoon.fs"
local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"


-- cached logger
local logger = class.new("lemoon.log","gsmake")

local module = {}

function module.ctor(name,owner)

    local obj = {
        Name        = name                                         ; -- plugin name
        Version     = owner.Loader.Config.DefaultVersion           ; -- plugin version
        Owner       = owner                                        ; -- the package plugin belongs to
        Tasks       = {}                                           ; -- plugin register task list
    }

    return obj
end

function module:version(version)
    self.Version = version
end

-- load plugin's package
function module:load()

    local sync   = self.Owner.Loader.Sync
    local gsmake = self.Owner.Loader.GSMake
    -- first sync the plugin's package
    local sourcePath = sync:sync(self.Name,self.Version)

    self.Loader  = class.new("gsmake.loader",gsmake,sourcePath,self.Name,self.Version)

    self.Package = self.Loader:load()

    local subdir = self.Name:gsub("%.","/")

    return self.Package
end

-- install plugin package and load plugin
function module:setup()
    self.Loader:setup()
    -- first install plugin into target path
    self.Loader:run("install",self.Owner.Loader.Temp)
    -- the plugin install path
    self.Path = filepath.join(self.Owner.Loader.Temp,"gsmake",self.Name)
    -- second load the plugin
    local pluginMain = filepath.join(self.Path,"plugin.lua")

    local sandbox = class.new("lemoon.sandbox","gsmake.sandbox.plugin",self,self.Path)

    sandbox:run(pluginMain)
end

return module

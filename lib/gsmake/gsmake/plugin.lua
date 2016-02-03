local fs        = require "lemoon.fs"
local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

local logger    = class.new("lemoon.log","gsmake")
local console   = class.new("lemoon.log","console")
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

    logger:I("[%s:%s] sync plugin package [%s:%s]",self.Owner.Name,self.Owner.Version,self.Name,self.Version)
    -- first sync the plugin's package
    local sourcePath = sync:sync(self.Name,self.Version)

    logger:I("[%s:%s] sync plugin package [%s:%s] -- success\n\tpath :%s",self.Owner.Name,self.Owner.Version,self.Name,self.Version,sourcePath)

    logger:I("[%s:%s] load plugin package [%s:%s]\n\tpath :%s",self.Owner.Name,self.Owner.Version,self.Name,self.Version,sourcePath)

    self.Loader  = class.new("gsmake.loader",gsmake,sourcePath,self.Name,self.Version)

    self.Package = self.Loader:load()

    logger:I("[%s:%s] load plugin package [%s:%s] -- success\n\tpath :%s",self.Owner.Name,self.Owner.Version,self.Name,self.Version,sourcePath)

    return self.Package
end

-- install plugin package and load plugin
function module:setup()

    logger:I("[%s:%s] setup plugin package [%s:%s]\n\tpath :%s",self.Owner.Name,self.Owner.Version,self.Name,self.Version,self.Package.Path)
    self.Loader:setup()
    logger:I("[%s:%s] setup plugin package [%s:%s] -- success\n\tpath :%s",self.Owner.Name,self.Owner.Version,self.Name,self.Version,self.Package.Path)
    -- the plugin install path
    self.Path = filepath.join(self.Owner.Loader.Temp,"gsmake",self.Name)
    -- first install plugin into target path
    logger:I("[%s:%s] install plugin package [%s:%s]\n\tinstall path :%s",self.Owner.Name,self.Owner.Version,self.Name,self.Version,self.Owner.Loader.Temp)
    self.Loader:run("install",self.Path)
    logger:I("[%s:%s] install plugin package [%s:%s] -- success\n\tinstall path :%s",self.Owner.Name,self.Owner.Version,self.Name,self.Version,self.Owner.Loader.Temp)
    -- second load the plugin
    local pluginMain = filepath.join(self.Path,"gsmake","plugin.lua")

    local sandbox = class.new("lemoon.sandbox","gsmake.sandbox.plugin",self,self.Path)

    sandbox:run(pluginMain)
end

return module

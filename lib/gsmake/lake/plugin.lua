local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"


-- cached logger
local logger = class.new("lemoon.log","lake")

local module = {}
function module.ctor(name,owner)

    local obj = {
        Name        = name                                         ; -- plugin name
        Version     = owner.lake.Config.GSMAKE_DEFAULT_VERSION     ; -- plugin version
        Config      = owner.lake.Config                            ; -- gsmake config
        Owner       = owner                                        ; -- the package plugin belongs to
        Tasks       = {}                                           ; -- plugin register task list
        InstallDir  = owner.lake.Config.GSMAKE_INSTALL_PATH        ; -- plugin install path
        sync        = owner.lake.Sync                              ; -- gsmake sync service
        loader      = owner.lake.Loader                            ; -- gsmake context
    }

    return obj
end

function module:version(version)
    self.Version = version
end

function module:load()
    -- first sync the plugin's package
    logger:D("sync plugin package [%s:%s]",self.Name,self.Version)
    local sourcePath = self.sync:sync(self.Name,self.Version)
    logger:D("sync plugin package [%s:%s] -- success\n\tpath :%s",self.Name,self.Version,sourcePath)

    self.Package = self.loader:load(sourcePath,self.Name,self.Version)

    local subdir = self.Name:gsub("%.","/")

    self.Path = filepath.join(self.InstallDir,"gsmake",self.Name)

    return self.Package

end

function module:setup()

    if not fs.exists(self.Path) then
        error(string.format("[%s:%s]'s plugin [%s:%s] not install ",self.Owner.Name,self.Owner.Version,self.Name,self.Version))
    end

    local pluginMain = filepath.join(self.Path,"plugin.lua")

    local sandbox = class.new("lemoon.sandbox","lake.sandbox.plugin",self,self.Path)

    sandbox:run(pluginMain)

end

return module

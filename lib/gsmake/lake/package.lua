-- the gsmake package module
local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

-- cached logger
local logger = class.new("lemoon.log","lake")

local module = {}

function module.ctor(lake,path,name,version)
    assert(fs.exists(path),"package path not exists")

    local obj =
    {
        lake        = lake                                           ;
        Lake        = lake                                           ;
        db          = lake.DB                                        ;
        Path        = path                                           ;
        Plugins     = {}                                             ; -- package scope register plugins
        Tasks       = {}                                             ; -- package scope register tasks
        Properties  = {}                                             ; -- package scrope properties
    }

    local gsmakeFilePath = filepath.join(path,lake.Config.GSMAKE_FILE)

    if fs.exists(gsmakeFilePath) then
        logger:V("found a standard lake package :%s",path)

        local sandbox = class.new("lemoon.sandbox","lake.sandbox.package",obj)

        sandbox:run(gsmakeFilePath)
    end

    if obj.Name == nil then
        obj.Name = name
    end

    if obj.Version == nil then
        obj.Version = version or  lake.Config.GSMAKE_DEFAULT_VERSION ;
    end

    return obj
end

function module:link()

    logger:I("load package [%s:%s] ... ",self.Name,self.Version)

    for _,plugin in pairs(self.Plugins) do

        -- install dependency plugin
        logger:D("[%s:%s] load and link plugin [%s:%s]",self.Name,self.Version,plugin.Name,plugin.Version)

        local package = plugin:load()

        package:link()

        logger:D("[%s:%s] load and link plugin [%s:%s] -- success",self.Name,self.Version,plugin.Name,plugin.Version)
    end


    logger:I("load package [%s:%s] -- success ",self.Name,self.Version)
end

function module:setup()

    for _,plugin in pairs(self.Plugins) do

        logger:D("[%s:%s] link plugin [%s:%s]",self.Name,self.Version,plugin.Name,plugin.Version)

        local package = plugin.Package

        local ok = self.db:query_install(package.Name,package.Version)

--        if not ok or not fs.isdir(plugin.Path) then -- link plugin

            class.new("lake",package.Path):run("install",plugin.InstallDir)

            self.db:save_install(package.Name,package.Version,package.Path,plugin.Path,true)

            logger:D("[%s:%s] link plugin [%s:%s] -- success",self.Name,self.Version,plugin.Name,plugin.Version)

--        end

        logger:D("[%s:%s] setup plugin [%s:%s]",self.Name,self.Version,plugin.Name,plugin.Version)

        plugin:setup()

        logger:D("[%s:%s] setup plugin [%s:%s] -- success",self.Name,self.Version,plugin.Name,plugin.Version)
    end
end


return module
